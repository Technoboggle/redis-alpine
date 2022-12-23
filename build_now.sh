#!/usr/bin/env sh

owd="`pwd`"
cd "$(dirname "$0")"

redis_ver="7.0.6"
alpine_ver="3.17.0"

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c *
find $(pwd) -type d -exec chmod ugo+x {} \;
find $(pwd) -type f -exec chmod ugo=wr {} \;
find $(pwd) -type f \( -iname \*.sh -o -iname \*.py \) -exec chmod ugo+x {} \;

docker login
docker build -f Dockerfile -t technoboggle/redis-alpine:"$redis_ver-$alpine_ver" --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg VCS_REF="`git rev-parse --verify HEAD`" --build-arg BUILD_VERSION=0.05 --force-rm --no-cache .
#--progress=plain 

docker run -it -d --rm -p 16279:6279 --rm --name myredis technoboggle/redis-alpine:"$redis_ver-$alpine_ver"
#docker tag technoboggle/redis-alpine:"$redis_ver-$alpine_ver" technoboggle/redis-alpine:latest

docker push technoboggle/redis-alpine:"$redis_ver-$alpine_ver"
#docker push technoboggle/redis-alpine:latest
docker container stop -t 10 myredis

cd "$owd"
