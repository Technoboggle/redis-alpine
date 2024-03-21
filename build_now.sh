#!/usr/bin/env sh

owd="$(pwd)"
cd "$(dirname "$0")" || exit

if [ -f .env ]; then
    export $(cat .env | xargs)
fi

if [ -f .perms ]; then
    export $(cat .perms | xargs)
fi

export DOCKERCMD="docker run -it -d -p 16379:6379 --rm --name myredis technoboggle/redis-alpine:${REDIS_VERSION}-${ALPINE_VERSION}"
echo ${ALPINE_VERSION}

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c ./*
find "$(pwd)" -type d -exec chmod ugo+x {} \;
find "$(pwd)" -type f -exec chmod ugo=wr {} \;
find "$(pwd)" -type f \( -iname \*.sh -o -iname \*.py \) -exec chmod ugo+x {} \;

current_builder=$(docker buildx ls | grep -i '\*' | head -n1 | awk '{print $1;}')

docker buildx create --name tb_redis_builder --use --bootstrap

docker login -u="${DOCKER_USER}" -p="${DOCKER_PAT}"

docker buildx build -f Dockerfile \
    --platform linux/arm64,linux/amd64,linux/amd64/v2,linux/386,linux/armhf,linux/s390x,linux/ppc64le \
    -t technoboggle/redis-alpine:"${REDIS_VERSION}-${ALPINE_VERSION}" \
    --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --build-arg VCS_REF="$(git rev-parse --verify HEAD)" \
    --build-arg ALPINE_VERSION="${ALPINE_VERSION}" \
    --progress=plain \
    --force-rm \
    --no-cache \
    --push .

# --env-file .env \

docker run -it -d --rm -p 16279:6279 --rm --name myredis technoboggle/redis-alpine:"${REDIS_VERSION}-${ALPINE_VERSION}"
docker container stop -t 10 myredis

docker buildx use "${current_builder}"
docker buildx rm tb_redis_builder

cd "$owd" || exit
