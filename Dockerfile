ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION}

# Technoboggle Build time arguments.
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

ARG REDIS_VERSION=${REDIS_VERSION}
ARG REDIS_DOWNLOAD_URL=${REDIS_DOWNLOAD_URL}
ARG REDIS_DOWNLOAD_SHA=${REDIS_SHA}


# Technoboggle Build time arguments.
ARG BUILD_DATE="${BUILD_DATE}"
ARG VCS_REF="${VCS_REF}"
ARG BUILD_VERSION="${BUILD_VERSION}"

ARG POSTFIX_VERSION="${POSTFIX_VERSION}"
ARG MAINTAINER="${MAINTAINER}"
ARG AUTHORNAME="${AUTHORNAME}"
ARG AUTHORS="${AUTHORS}"
ARG VERSION="${VERSION}"

ARG SCHEMAVERSION="${SCHEMAVERSION}"
ARG NAME="${NAME}"
ARG DESCRIPTION="${DESCRIPTION}"
ARG URL="${URL}"
ARG VCS_URL="${VCS_URL}"
ARG VENDOR="${VENDOR}"
ARG BUILDVERSION="${BUILDVERSION}"


# Labels.
LABEL maintainer=${MAINTAINER}
LABEL net.technoboggle.authorname=${AUTHORNAME} \
      net.technoboggle.authors=${AUTHORS} \
      net.technoboggle.version=${VERSION} \
      net.technoboggle.description=${DESCRIPTION} \
      net.technoboggle.buildDate=${BUILD_DATE}

LABEL org.label-schema.schema-version=${SCHEMAVERSION}
LABEL org.label-schema.build-date=${BUILD_DATE}
LABEL org.label-schema.name=${NAME}
LABEL org.label-schema.description=${DESCRIPTION}
LABEL org.label-schema.url=${URL}
LABEL org.label-schema.vcs-url=${VCS_URL}
LABEL org.label-schema.vcs-ref=${VSC_REF}
LABEL org.label-schema.vendor=${VENDOR}
LABEL org.label-schema.version=${BUILDVERSION}
LABEL org.label-schema.docker.cmd=${DOCKERCMD}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN apk update --no-cache && \
    apk upgrade --no-cache && \
  \
  addgroup -S -g 1000 redis && adduser -S -G redis -u 999 redis;\
# alpine already has a gid 999, so we'll use the next id
  \
    apk add --no-cache \
# grab su-exec for easy step-down from root
    'su-exec>=0.2' \
# add tzdata for https://github.com/docker-library/redis/issues/138
    tzdata; \
  \
    set -eux; \
    apk --no-cache upgrade musl &&\
    apk add --no-cache --virtual .build-deps \
    coreutils \
    dpkg-dev dpkg \
    gcc \
    linux-headers \
    make \
    musl-dev \
    openssl-dev \
# install real "wget" to avoid:
#   + wget -O redis.tar.gz http://download.redis.io/releases/redis-6.0.6.tar.gz
#   Connecting to download.redis.io (45.60.121.1:80)
#   wget: bad header line:     XxhODalH: btu; path=/; Max-Age=900
    wget;
RUN wget -O redis.tar.gz "http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz" && \
  echo "Expecting: $(sha256sum *redis.tar.gz)"; \
  echo "$REDIS_DOWNLOAD_SHA *redis.tar.gz" | sha256sum -c -; \
  mkdir -p /usr/src/redis; \
  tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
  rm redis.tar.gz; \
  \
# disable Redis protected mode [1] as it is unnecessary in context of Docker
# (ports are not automatically exposed when running inside Docker, but rather explicitly by specifying -p / -P)
# [1]: https://github.com/redis/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
  grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' /usr/src/redis/src/config.c; \
  sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' /usr/src/redis/src/config.c; \
  grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' /usr/src/redis/src/config.c; \
# for future reference, we modify this directly in the source instead of just supplying a default configuration flag because apparently "if you specify any argument to redis-server, [it assumes] you are going to specify everything"
# see also https://github.com/docker-library/redis/issues/4#issuecomment-50780840
# (more exactly, this makes sure the default behavior of "save on SIGTERM" stays functional by default)
  \
# https://github.com/jemalloc/jemalloc/issues/467 -- we need to patch the "./configure" for the bundled jemalloc to match how Debian compiles, for compatibility
# (also, we do cross-builds, so we need to embed the appropriate "--build=xxx" values to that "./configure" invocation)
  gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
  extraJemallocConfigureFlags="--build=$gnuArch"; \
# https://salsa.debian.org/debian/jemalloc/-/blob/c0a88c37a551be7d12e4863435365c9a6a51525f/debian/rules#L8-23
  dpkgArch="$(dpkg --print-architecture)"; \
  case "${dpkgArch##*-}" in \
    amd64 | i386 | x32) extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-page=12" ;; \
    *) extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-page=16" ;; \
  esac; \
  extraJemallocConfigureFlags="$extraJemallocConfigureFlags --with-lg-hugepage=21"; \
  grep -F 'cd jemalloc && ./configure ' /usr/src/redis/deps/Makefile; \
  sed -ri 's!cd jemalloc && ./configure !&'"$extraJemallocConfigureFlags"' !' /usr/src/redis/deps/Makefile; \
  grep -F "cd jemalloc && ./configure $extraJemallocConfigureFlags " /usr/src/redis/deps/Makefile; \
  \
  export BUILD_TLS=yes; \
  make -C /usr/src/redis -j "$(nproc)" all; \
  make -C /usr/src/redis install; \
  \
# TODO https://github.com/redis/redis/pull/3494 (deduplicate "redis-server" copies)
  serverMd5="$(md5sum /usr/local/bin/redis-server | cut -d' ' -f1)"; export serverMd5; \
  find /usr/local/bin/redis* -maxdepth 0 \
    -type f -not -name redis-server \
    -exec sh -eux -c ' \
      md5="$(md5sum "$1" | cut -d" " -f1)"; \
      test "$md5" = "$serverMd5"; \
    ' -- '{}' ';' \
    -exec ln -svfT 'redis-server' '{}' ';' \
  ; \
  \
  rm -r /usr/src/redis; \
  \
  runDeps="$( \
    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
      | tr ',' '\n' \
      | sort -u \
      | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  )"; \
  apk add --no-network --virtual .redis-rundeps $runDeps; \
  apk del --no-network .build-deps; \
  \
  redis-cli --version; \
  redis-server --version; \
  mkdir /data; \
  chown redis:redis /data;

#VOLUME /data
WORKDIR /usr/local/bin/

COPY docker-entrypoint.sh /usr/local/bin/
#ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6279
#CMD ["redis-server /usr/local/etc/redis/redis.conf"]
