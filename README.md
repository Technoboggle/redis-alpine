
[![Known Vulnerabilities](https://snyk.io/test/github/Technoboggle/postfix-alpine/badge.svg)](https://snyk.io/test/github/Technoboggle/redis-alpine)



![Trueosiris Rules](https://img.shields.io/badge/trueosiris-rules-f08060)

[![Docker Pulls](https://badgen.net/docker/pulls/technoboggle/redis-alpine?icon=docker&label=pulls)](https://hub.docker.com/r/trueosiris/godaddypy/)
[![Docker Stars](https://badgen.net/docker/stars/technoboggle/redis-alpine?icon=docker&label=stars)](https://hub.docker.com/r/trueosiris/godaddypy/)
[![Docker Image Size](https://badgen.net/docker/size/technoboggle/redis-alpine?icon=docker&label=image%20size)](https://hub.docker.com/r/trueosiris/godaddypy/)

![Github stars](https://badgen.net/github/stars/technoboggle/redis-alpine?icon=github&label=stars)

![Github forks](https://badgen.net/github/forks/technoboggle/redis-alpine?icon=github&label=forks)

![Github issues](https://img.shields.io/github/issues/Technoboggle/redis-alpine)

![Github last-commit](https://img.shields.io/github/last-commit/Technoboggle/redis-alpine)




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


docker build -f Dockerfile --progress=plain -t technoboggle/redis-alpine:7.0.4-3.16.1 --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg VCS_REF="`git rev-parse --verify HEAD`" --build-arg BUILD_VERSION=0.05 --no-cache --progress=plain .

in the above pay special attenttion to the values to be updated which are:
  7.0.4-3.16.1                     =  redis version - alpine version
  "`git rev-parse --verify HEAD`"  = git commit SHA key
  0.05                             = current version of this image

docker run -it -d -p 16279:6279 --rm --name myredis technoboggle/redis-alpine:7.0.4-3.16.1
docker tag technoboggle/redis-alpine:7.0.4-3.16.1 technoboggle/redis-alpine:latest
docker login
docker push technoboggle/redis-alpine:7.0.4-3.16.1
docker push technoboggle/redis-alpine:latest
docker container stop -t 10 myredis
#####################################################################
```

# To force a complete rebuild
export BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') && docker-compose -f docker-compose.yml build --force-rm --no-cache --progress=plain redis

docker-compose -f docker-compose.yml up -d redis
