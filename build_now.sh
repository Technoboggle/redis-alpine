#!/usr/bin/env sh

owd="$(pwd)"
cd "$(dirname "$0")" || exit

BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
VCS_REF="$(git rev-parse --verify HEAD)"

export BUILD_DATE
export VCS_REF

sed -i.bu -E 's/BUILD_DATE=".*"/BUILD_DATE="'"${BUILD_DATE}"'"/g' env.hcl
sed -i.bu -E 's/VCS_REF=".*"/VCS_REF="'"${VCS_REF}"'"/g' env.hcl

DOCKERCMD='docker run -it -d -p 16379:6379 --rm --name myredis technoboggle/redis-alpine:'"${REDIS_VERSION}-${ALPINE_VERSION}"
export DOCKERCMD

sed -i.bu -E 's#DOCKERCMD=".*"#DOCKERCMD="'"${DOCKERCMD}"'"#g' env.hcl

if [ -f env.hcl ]; then
    export $(cat env.hcl | xargs)
fi

if [ -f .perms ]; then
    export $(cat .perms | xargs)
fi

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c ./*
find "$(pwd)" -type d -exec chmod ugo+x {} \;
find "$(pwd)" -type f -exec chmod ugo=wr {} \;
find "$(pwd)" -type f \( -iname \*.sh -o -iname \*.py \) -exec chmod ugo+x {} \;

#current_builder=$(docker buildx ls | grep -i 'docker\-container' | head -n1 | awk '{print $1;}')
current_builder=$(docker buildx ls | grep -i '\s\*' | head -n1 | awk '{print $1;}')

docker buildx create --name technoboggle_builder --use --bootstrap --platform=linux/arm/v7,linux/arm64,linux/amd64,linux/arm64/v8,linux/386,linux/armhf,linux/s390x,linux/arm/v7,linux/arm/v6,linux/ppc64le

docker login -u="${DOCKER_USER}" -p="${DOCKER_PAT}"

docker buildx bake -f docker-bake.hcl -f env.hcl --no-cache --push

sed -i.bu -E 's/BUILD_DATE=".*"/BUILD_DATE=""/g' env.hcl
sed -i.bu -E 's/VCS_REF=".*"/VCS_REF=""/g' env.hcl
sed -i.bu -E 's/DOCKERCMD=".*"/DOCKERCMD=""/g' env.hcl

rm -f env.hcl.bu

docker run -it -d --rm -p 16279:6279 --rm --name myredis technoboggle/redis-alpine:"${REDIS_VERSION}-${ALPINE_VERSION}"
docker container stop -t 10 myredis

docker buildx use "${current_builder}"
docker buildx rm technoboggle_builder

cd "$owd" || exit
