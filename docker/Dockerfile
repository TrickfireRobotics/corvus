# mavlink-router, built from source in a throwaway stage.
# Final image is ~40 MB: the binary plus its runtime libs.
#
# Published multi-arch (Pi is arm64, dev laptops are amd64):
#   docker buildx build --platform linux/arm64,linux/amd64 \
#     -f docker/Dockerfile \
#     -t ghcr.io/trickfirerobotics/corvus-mavlink-router:latest --push .

FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates meson ninja-build pkg-config gcc g++ python3 \
        libsystemd-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --recurse-submodules --depth 1 \
        https://github.com/mavlink-router/mavlink-router.git . \
    && meson setup build . --buildtype=release \
    && ninja -C build

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        libstdc++6 libsystemd0 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /src/build/src/mavlink-routerd /usr/bin/mavlink-routerd

# docker-compose mounts the config file here (read-only).
ENTRYPOINT ["/usr/bin/mavlink-routerd"]
CMD ["-c", "/config/main.conf"]
