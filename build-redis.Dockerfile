FROM alpine:3.12.3
MAINTAINER edward.finlayson@btinternet.com

ARG BUILD_DATE
ARG VCS_REF
#ARG REDIS_SRC_URL="http://download.redis.io/releases/redis-stable.tar.gz"
ARG REDIS_SRC_URL="https://download.redis.io/releases/redis-6.0.9.tar.gz"

LABEL org.label-schema.build-date=$BUILD_DATE\
      org.label-schema.vcs-url="https://github.com/webcanyon/docker-alpine-redis-cluster.git"\
      org.label-schema.vcs-ref=$VCS_REF\
      org.label-schema.name="Development Redis Cluster"\
      org.label-schema.description="Image for easy testing apps with redis cluster."\
      org.label-schema.usage="https://github.com/webcanyon/docker-alpine-redis-cluster"\
      org.label-schema.schema-version="v1.0.0"

RUN apk add --no-cache --update ruby ruby-irb ruby-rake ruby-io-console ruby-bigdecimal ruby-json ruby-bundler

RUN set -x\
 && apk add --no-cache --virtual .build-apks\
  curl\
  gcc\
  linux-headers\
  make\
  musl-dev\
  tar\
 && curl -o redis.tar.gz "$REDIS_SRC_URL"\
 && mkdir -p /usr/src/redis\
 && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1\
 && rm redis.tar.gz\
 && make -C /usr/src/redis\
 && make -C /usr/src/redis install\
 && apk del .build-apks\
 && apk add --no-cache bash

VOLUME /redis/data /redis/modules
WORKDIR /redis/data

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
RUN gem help install
RUN gem install -N redis
WORKDIR /usr/src/redis/src/

ENTRYPOINT ["/entrypoint.sh"]
