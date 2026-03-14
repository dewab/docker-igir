# Igir Container

This project builds a minimal runtime image for the `igir` CLI and publishes it from [dewab/docker-igir](https://github.com/dewab/docker-igir) to `ghcr.io`.

## Design

- Pinned Igir release via `ARG IGIR_VERSION`
- Host-side vendoring of `igir` and its dependencies to avoid registry access during `container build`
- Non-root runtime user
- Runtime drops `npm`, `npx`, and `corepack` to reduce attack surface
- OCI labels for Docker Hub and registry metadata
- Default entrypoint runs `igir` via `node`

## Defaults

- Repository: `https://github.com/dewab/docker-igir`
- Published image: `ghcr.io/dewab/docker-igir`
- Current Igir version: `4.3.2`
- Primary release tag: `ghcr.io/dewab/docker-igir:4.3.2`
- Default target platform: `linux/amd64`

## Build

```bash
cd /Users/daniel/docker/igir

container build \
  --platform linux/amd64 \
  --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg VCS_REF="$(git rev-parse --short HEAD 2>/dev/null || printf unknown)" \
  -t ghcr.io/dewab/docker-igir:4.3.2 .
```

Or use the repeatable target:

```bash
make build
```

`make build` first vendors `igir@4.3.2` for `linux/amd64` on the host, then runs an offline `container build`.

If you need a host-arch-only build while debugging:

```bash
make build-single
```

## Validate And Scan

Smoke test the built image:

```bash
make smoke
```

Scan the Dockerfile configuration:

```bash
make scan-config
```

Save the local image and scan it with Trivy before publishing:

```bash
make scan-image
```

`scan-image` saves and scans the configured `PLATFORM`. By default, that is `linux/amd64`.

Lint the repo and GitHub Actions locally:

```bash
make lint
```

## Publish

GitHub Actions workflow:

```bash
/.github/workflows/publish-ghcr.yml
```

On `main` branch pushes and manual runs, the workflow will:

- Vendor `igir` for `linux/amd64` on the runner
- Run `pre-commit` across the repo, including GitHub Actions YAML
- Build the image
- Smoke test `--version`
- Run Trivy filesystem and image scans
- Push `ghcr.io/dewab/docker-igir:<IGIR_VERSION>`
- Push `ghcr.io/dewab/docker-igir:latest` on the default branch

## Usage

Show help:

```bash
docker run --rm ghcr.io/dewab/docker-igir:4.3.2
```

Mount ROMs, DATs, and output directories:

```bash
container run --rm -it \
  --volume /path/to/roms:/data/in:ro \
  --volume /path/to/dats:/data/dats:ro \
  --volume /path/to/output:/data/out \
  ghcr.io/dewab/docker-igir:4.3.2 \
  copy zip test \
  --dat /data/dats/*.zip \
  --input /data/in \
  --output /data/out
```

## Notes

- Keep source ROM and DAT mounts read-only when possible.
- The GitHub Actions workflow publishes the version tag that matches `IGIR_VERSION` and publishes `latest` from the default branch.
- The `Lint` workflow and the publish workflow both run `pre-commit` so repo files and GitHub Actions definitions are checked in CI.
- This repo now targets `linux/amd64` by default to match the requested published artifact and simplify validation/remediation.
- The workflow vendors a `linux/amd64` dependency tree on the runner before the image build so the Docker build itself does not need npm registry access.
- Update `IGIR_VERSION` deliberately rather than floating to the newest release at build time.
