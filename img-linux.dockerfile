#
# Container Image Consul
#

FROM alpine:3.16.2

ARG PROJ_NAME
ARG PROJ_VERSION
ARG PROJ_BUILD_NUM
ARG PROJ_BUILD_DATE
ARG PROJ_REPO
ARG TARGETOS
ARG TARGETARCH

LABEL org.opencontainers.image.authors="V10 Solutions"
LABEL org.opencontainers.image.title="${PROJ_NAME}"
LABEL org.opencontainers.image.version="${PROJ_VERSION}"
LABEL org.opencontainers.image.revision="${PROJ_BUILD_NUM}"
LABEL org.opencontainers.image.created="${PROJ_BUILD_DATE}"
LABEL org.opencontainers.image.description="Container image for Consul"
LABEL org.opencontainers.image.source="${PROJ_REPO}"

RUN apk update \
	&& apk add --no-cache "shadow" "bash" \
	&& usermod -s "$(command -v "bash")" "root"

SHELL [ \
	"bash", \
	"--noprofile", \
	"--norc", \
	"-o", "errexit", \
	"-o", "nounset", \
	"-o", "pipefail", \
	"-c" \
]

ENV LANG "C.UTF-8"
ENV LC_ALL "${LANG}"

RUN apk add --no-cache \
	"ca-certificates" \
	"curl" \
	"jq"

RUN groupadd -r -g "480" "consul" \
	&& useradd \
		-r \
		-m \
		-s "$(command -v "nologin")" \
		-g "consul" \
		-c "Consul" \
		-u "480" \
		"consul"

WORKDIR "/tmp"

RUN curl -L -f -o "consul.zip" "https://releases.hashicorp.com/consul/${PROJ_VERSION}/consul_${PROJ_VERSION}_${TARGETOS}_${TARGETARCH}.zip" \
	&& unzip "consul.zip" \
	&& chmod "755" "consul" \
	&& mv "consul" "/usr/local/bin/" \
	&& rm "consul.zip"

WORKDIR "/usr/local"

RUN mkdir -p "etc/consul" \
	&& folders=("var/lib/consul" "var/run/consul") \
	&& for folder in "${folders[@]}"; do \
		mkdir -p "${folder}" \
		&& chmod "700" "${folder}" \
		&& chown -R "480":"480" "${folder}"; \
	done

WORKDIR "/"
