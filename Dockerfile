FROM golang:1.14.15-alpine3.13 as build
ARG VERSION
ARG CHECKSUM
WORKDIR /go/src/github.com/prologic/shorturl
ARG FILENAME="${VERSION}.tar.gz"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    wget=1.21.1-r1 \
    git=2.30.2-r0 \
    make=4.3-r0 \
    build-base=0.5-r2 && \
  echo "**** download haste ****" && \
  mkdir /app && \
  wget -nv "https://github.com/prologic/shorturl/archive/${FILENAME}" && \
  echo "${CHECKSUM}  ${FILENAME}" | sha256sum -c && \
  tar -xvf "${FILENAME}" --strip-components 1 && \
  make TAG=$VERSION BUILD=dev build

FROM ghcr.io/linuxserver/baseimage-alpine:3.14
ARG BUILD_DATE
ARG VERSION
WORKDIR /
# hadolint ignore=DL3048
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="nicholaswilde"
COPY --from=build --chown=abc:abc /go/src/github.com/prologic/shorturl/shorturl /app/shorturl
COPY root/ .
RUN \
  mkdir /data && \
  chown -R abc:abc /data
EXPOSE 8000/tcp
VOLUME \
  /app \
  /data
