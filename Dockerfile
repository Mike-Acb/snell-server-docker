FROM --platform=$BUILDPLATFORM tonistiigi/xx:latest AS xx

FROM --platform=$BUILDPLATFORM frolvlad/alpine-glibc:alpine-3.16 AS build

COPY --from=xx / /
ARG TARGETPLATFORM
ARG VERSION

RUN apk add --no-cache --update wget unzip && \
    xx-info env && \
    ARCH=$(xx-info arch) && \
    case ${ARCH} in \
        amd64) ARCH_SUFFIX="amd64" ;; \
        arm64) ARCH_SUFFIX="aarch64" ;; \
        arm) ARCH_SUFFIX="armv7l" ;; \
        *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
    esac && \
    DOWNLOAD_URL="https://dl.nssurge.com/snell/snell-server-v${VERSION}-linux-${ARCH_SUFFIX}.zip" && \
    echo "Downloading Snell Server from ${DOWNLOAD_URL}" && \
    wget -q -O "snell-server.zip" "${DOWNLOAD_URL}" && \
    unzip snell-server.zip && \
    rm snell-server.zip && \
    xx-verify /snell-server

FROM frolvlad/alpine-glibc:alpine-3.16

ENV TZ=UTC

COPY --from=build /snell-server /usr/bin/snell-server
COPY start.sh /start.sh
RUN apk add --update --no-cache libstdc++

ENTRYPOINT /start.sh
