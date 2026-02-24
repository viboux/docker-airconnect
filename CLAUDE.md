# CLAUDE.md — AI Assistant Guide for docker-airconnect

## Project Overview

This repository provides a minimal Docker wrapper for [AirConnect](https://github.com/philippe44/AirConnect), a tool that bridges AirPlay with Sonos speakers and Google Cast devices. The project consists of a single `Dockerfile` and a `README.md`.

## Repository Structure

```
docker-airconnect/
├── Dockerfile    # Single build file; downloads and runs the AirConnect binary
└── README.md     # End-user documentation
```

There are no shell scripts, CI/CD pipelines, package manifests, or helper utilities.

## Dockerfile Anatomy

```dockerfile
FROM debian:stretch-slim
RUN apt-get update && apt-get -y install wget
RUN wget https://raw.githubusercontent.com/philippe44/AirConnect/master/bin/aircast-x86-64 \
  && chmod +x aircast-x86-64 && mv aircast-x86-64 /bin
RUN wget http://security-cdn.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb \
  && dpkg -i ./libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb
ENTRYPOINT ["/bin/aircast-x86-64", "-Z", "-k"]
```

### What each layer does

| Layer | Purpose |
|---|---|
| `FROM debian:stretch-slim` | Lightweight Debian 9 base image |
| `apt-get install wget` | Installs the download tool needed for subsequent steps |
| Download `aircast-x86-64` | Fetches the pre-compiled AirConnect binary from upstream master; makes it executable; places it in `/bin` |
| Download & install `libssl1.0.0` | Installs the OpenSSL 1.0.x shared library required by the binary (the binary was compiled against the older ABI) |
| `ENTRYPOINT` | Runs AirConnect with `-Z` (disable SSL certificate verification) and `-k` (keep running / do not exit on cast device loss) |

### Key constraints

- **Architecture**: The binary is `x86-64` only. This image will not work on ARM (Raspberry Pi, Apple Silicon, etc.) without rebuilding with an ARM binary.
- **Base image**: `debian:stretch-slim` (Debian 9, reached end-of-life June 2022). `apt` sources may become unavailable over time; updating to a newer Debian base will require verifying OpenSSL compatibility.
- **Binary source**: The Dockerfile always pulls from the upstream `master` branch at build time, so image rebuilds may pick up new upstream versions automatically.
- **Network mode**: The container **must** be run with `--net="host"` for mDNS/SSDP service discovery to work. Bridge networking will silently break AirPlay and Cast discovery.

## Running the Image

```bash
# Pull and run (published image)
docker run -d --net="host" swilsonau/docker-airconnect

# Build locally and run
docker build -t docker-airconnect .
docker run -d --net="host" docker-airconnect
```

No volumes, environment variables, or port mappings are required or supported by the current configuration.

## Development Workflow

Because the project is a single Dockerfile with no test suite or build tooling, the workflow is straightforward:

1. **Edit** `Dockerfile`.
2. **Build** the image locally: `docker build -t docker-airconnect .`
3. **Run** the container: `docker run -d --net="host" docker-airconnect`
4. **Verify** via logs: `docker logs <container-id>`
5. **Commit** and push changes to the appropriate branch.

There is no linter, formatter, or test runner to execute before committing.

## Git Conventions

- The default branch is `master`.
- Feature/fix branches follow the pattern `<username>/<description>` (e.g., `claude/add-claude-documentation-p2qri`).
- Commit messages are short, imperative-style summaries (e.g., `Fix bugs`, `Change default run parameter -z`).
- GPG signing via SSH key is configured for commits made from the automated environment.

## Upstream Dependency

| Component | Source |
|---|---|
| AirConnect binary (`aircast-x86-64`) | https://github.com/philippe44/AirConnect (fetched at build time from `master`) |
| OpenSSL 1.0.0 library | Debian 8 security archive (`libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb`) |

When the upstream AirConnect project releases a new binary, rebuilding the Docker image without any code changes will pick it up automatically.

## Known Issues and Limitations

- **No CI/CD**: There are no automated build or push pipelines. Image publishing is manual.
- **Stale base image**: `debian:stretch-slim` is EOL. The `apt` package index and security CDN URLs in the Dockerfile may break.
- **No configuration support**: AirConnect supports many runtime flags (interfaces, logging verbosity, etc.) but they are not exposed via environment variables or Docker entrypoint overrides in this image.
- **x86-64 only**: No multi-arch build support.

## Guidance for AI Assistants

- **Do not introduce new dependencies** without verifying compatibility with the Debian stretch base image.
- **Do not change the network mode** requirement (`--net="host"`) — it is fundamental to how AirPlay/Cast discovery works.
- **Prefer minimal changes**: this project intentionally does very little. Avoid adding complexity unless explicitly requested.
- **Test builds locally** before committing: `docker build -t docker-airconnect .` must succeed.
- **All changes go to a feature branch** matching the `claude/<description>-<session-id>` naming pattern; never push directly to `master`.
- **No formatting or linting tools** exist; there is nothing to run before committing.
