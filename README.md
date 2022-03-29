#####################################################################
# use the following commands to build image and upload to dockerhub #
```
#####################################################################

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c *
find $(pwd) -type d -exec chmod ugo+x {} \;
find $(pwd) -type f -exec chmod ugo=wr {} \;
find $(pwd) -type f \( -iname \*.sh -o -iname \*.py \) -exec chmod ugo+x {} \;


docker build -f Dockerfile --progress=plain -t technoboggle/redis-alpine:6.2.6-3.15.0 --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg VCS_REF=7aa4f4fed2822afd7ae0f083526aaba6ea502ca9 --build-arg BUILD_VERSION=0.04 --no-cache --progress=plain .
docker run -it -d -p 16379:6379 --rm --name myredis technoboggle/redis-alpine:6.2.6-3.15.0
docker tag technoboggle/redis-alpine:6.2.6-3.15.0 technoboggle/redis-alpine:latest
docker login
docker push technoboggle/redis-alpine:6.2.6-3.15.0
docker push technoboggle/redis-alpine:latest
docker container stop -t 10 myredis
#####################################################################
```

# To force a complete rebuild
export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') && docker-compose -f docker-compose.yml build --force-rm --no-cache --progress=plain php2

docker-compose -f docker-compose.yml up -d php2
