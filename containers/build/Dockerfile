# ─────────────────────────────────────────────────────────────────────────────
#  Build container — nRF52 Factory Erase firmware
#
#  Produces release ZIPs for all softdevice variants via PlatformIO.
#
#  Build (from project root):
#    docker build -f containers/build/Dockerfile -t nrf52-factory-erase-build .
#
#  Run (mounts build/ and release/ so artifacts land on the host):
#    docker run --rm \
#      -v "$(pwd)/build:/workspace/build" \
#      -v "$(pwd)/release:/workspace/release" \
#      nrf52-factory-erase-build
#
#  Override environment:
#    docker run --rm \
#      -v "$(pwd)/build:/workspace/build" \
#      -v "$(pwd)/release:/workspace/release" \
#      nrf52-factory-erase-build bash scripts/linux/release-nrf52.sh s140_nrf52_611_softdevice
#
#  Via Compose:
#    docker compose -f containers/docker-compose.yml run --rm build
# ─────────────────────────────────────────────────────────────────────────────

# ── Stage 1: base image with Python + PlatformIO ─────────────────────────────
FROM debian:bookworm-slim AS base

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LANG=C.UTF-8 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install --no-install-recommends -y \
        python3 python3-pip git ca-certificates zip curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 builder \
    && useradd -m -l -u 1000 -g 1000 builder

USER builder
WORKDIR /workspace

RUN pip3 install --user --no-cache-dir --break-system-packages "platformio==6.1.15"
ENV PATH="/home/builder/.local/bin:${PATH}"

# ── Stage 2: pre-warm PlatformIO package cache ────────────────────────────────
FROM base AS packages

# Copy only the files needed to resolve packages (improves layer caching).
# scripts/python/ is needed because platformio.ini references platformio-custom.py
# as an extra_scripts entry that PlatformIO resolves during config parsing.
COPY --chown=builder:builder platformio.ini arch/ variants/ boards/ scripts/ ./
RUN pio pkg install -e s140_nrf52_611_softdevice \
    && pio pkg install -e s140_nrf52_730_softdevice

# ── Stage 3: full build ───────────────────────────────────────────────────────
FROM packages AS build

COPY --chown=builder:builder . .

# Ensure output directories exist inside the container
RUN mkdir -p build release

# APP_VERSION is injected at runtime via the container environment
# (see containers/docker-compose.yml) so the image layer can be cached
# and reused across versions.

CMD ["bash", "scripts/linux/release-nrf52.sh", "all"]
