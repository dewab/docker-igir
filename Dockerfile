FROM node:22-bookworm-slim

ARG IGIR_VERSION=4.3.2
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=${IGIR_VERSION}

LABEL org.opencontainers.image.title="Igir" \
      org.opencontainers.image.description="Containerized Igir CLI for ROM verification, sorting, and maintenance" \
      org.opencontainers.image.url="https://github.com/dewab/docker-igir" \
      org.opencontainers.image.source="https://github.com/dewab/docker-igir" \
      org.opencontainers.image.vendor="Daniel" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

ENV NODE_ENV=production \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    HOME=/home/node \
    IGIR_INPUT=/data/in \
    IGIR_OUTPUT=/data/out \
    IGIR_DATS=/data/dats

COPY .vendor/igir-linux-x64/node_modules/igir /usr/local/lib/node_modules/igir
COPY .vendor/igir-linux-x64/node_modules /opt/igir-node_modules

RUN rm -rf /opt/igir-node_modules/npm /opt/igir-node_modules/corepack \
    && rm -f /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack \
    && ln -s /opt/igir-node_modules /usr/local/lib/node_modules/igir/node_modules \
    && mkdir -p /data/in /data/out /data/dats \
    && chown -R node:node /data /home/node

USER node:node
WORKDIR /work

VOLUME ["/data/in", "/data/out", "/data/dats"]

ENTRYPOINT ["node", "/usr/local/lib/node_modules/igir/dist/index.js"]
CMD ["--help"]
