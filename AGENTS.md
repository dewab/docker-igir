# AGENTS Notes

Purpose: Handoff context for the Igir container project in `/Users/daniel/docker/igir`.

## Project Goal

Build and publish a robust, secure Docker image for the `igir` CLI to Docker Hub.

## Current State

- `Dockerfile` exists and is designed as a multi-stage build.
- Runtime image is based on `node:22-bookworm-slim`.
- `IGIR_VERSION` is pinned to `4.3.2`.
- Runtime uses a non-root user (`node`).
- `tini` is used as PID 1.
- OCI image labels are included for Docker Hub / registry metadata.
- `README.md` includes local build and multi-arch `buildx --push` examples.
- `.dockerignore` exists and keeps the build context minimal.

## Important Validation Status

- The Dockerfile has not yet been validated with a successful local `docker build`.
- Attempted build failed because Docker was not reachable on this host:
  - `Cannot connect to the Docker daemon at unix:///Users/daniel/.docker/run/docker.sock`

## What To Do Next

1. Ensure Docker Desktop or the local Docker daemon is running.
2. Run:
   - `docker build -t local/igir:test /Users/daniel/docker/igir`
   - `docker run --rm local/igir:test --version`
3. If the image builds successfully, optionally add:
   - a `Makefile` or `docker-bake.hcl` for repeatable builds
   - image scanning instructions
   - digest-pinning for the base image if stricter supply-chain controls are desired
4. Publish with `docker buildx build ... --push` using the commands in `README.md`.

## Constraints And Preferences

- Keep the image pinned to an explicit Igir version; do not switch to floating `latest` in the Dockerfile.
- Keep the runtime image non-root.
- Keep the runtime surface minimal; avoid adding unnecessary packages.
- Prefer reproducible, publishable Docker Hub metadata and tags.
- Favor ASCII-only edits unless the file already requires otherwise.

## Files

- `Dockerfile`
- `.dockerignore`
- `README.md`

## Notes

- If a future Codex instance changes the base image, package install flow, or entrypoint behavior, it should re-run the local build and container smoke test before publishing.
