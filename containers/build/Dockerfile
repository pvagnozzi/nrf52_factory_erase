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
#    APP_VERSION=1.2.3 docker compose -f containers/docker-compose.yml run --rm build
# ─────────────────────────────────────────────────────────────────────────────

FROM debian:bookworm-slim

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

COPY --chown=builder:builder . .
RUN mkdir -p build release

# APP_VERSION is injected at runtime (docker run -e APP_VERSION=1.2.3 ...)
# so this image layer can be reused across releases without rebuilding.

CMD ["bash", "scripts/linux/release-nrf52.sh", "all"]
