IMAGE ?= ghcr.io/dewab/docker-igir
IGIR_VERSION ?= 4.3.2
BUILD_DATE ?= $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
VCS_REF ?= $(shell git rev-parse --short HEAD 2>/dev/null || printf unknown)
PLATFORMS ?= linux/amd64
PLATFORM ?= $(firstword $(PLATFORMS))
IMAGE_REF := $(IMAGE):$(IGIR_VERSION)
LATEST_REF := $(IMAGE):latest
SCAN_ARCHIVE := /tmp/igir-$(IGIR_VERSION).oci.tar
VENDOR_DIR := .vendor/igir-linux-x64
PLATFORM_FLAGS := $(foreach platform,$(PLATFORMS),--platform $(platform))

.PHONY: vendor build build-single smoke save scan-config scan-image lint tag-latest publish clean

vendor:
	mkdir -p "$(VENDOR_DIR)"
	npm install \
		--prefix "$(VENDOR_DIR)" \
		--omit=dev \
		--cpu=x64 \
		--os=linux \
		--libc=glibc \
		"igir@$(IGIR_VERSION)"

build: vendor
	container build \
		$(PLATFORM_FLAGS) \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		-t "$(IMAGE_REF)" .

build-single: vendor
	container build \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		-t "$(IMAGE_REF)" .

smoke:
	container run --rm "$(IMAGE_REF)" --version

save:
	rm -f "$(SCAN_ARCHIVE)"
	container image save --platform "$(PLATFORM)" --output "$(SCAN_ARCHIVE)" "$(IMAGE_REF)"

scan-config:
	trivy config --severity HIGH,CRITICAL .

scan-image: save
	trivy image --input "$(SCAN_ARCHIVE)" --severity HIGH,CRITICAL --ignore-unfixed

lint:
	pre-commit run --all-files

tag-latest:
	container image tag "$(IMAGE_REF)" "$(LATEST_REF)"

publish: build smoke scan-config scan-image tag-latest
	container image push $(PLATFORM_FLAGS) "$(IMAGE_REF)"
	container image push $(PLATFORM_FLAGS) "$(LATEST_REF)"

clean:
	rm -f "$(SCAN_ARCHIVE)"
