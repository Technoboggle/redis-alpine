#####################################################################
# use the following commands to build image and upload to dockerhub #
```
#####################################################################
docker build -f build-redis.Dockerfile -t technoboggle/redis-alpine:6.0.9-3.12.3 .
docker run -it -d -p 8000:80 --rm --name myredis technoboggle/redis-alpine:6.0.9-3.12.3
docker tag technoboggle/redis-alpine:6.0.9-3.12.3 technoboggle/redis-alpine:latest
docker login
docker push technoboggle/redis-alpine:6.0.9-3.12.3
docker push technoboggle/redis-alpine:latest
docker container stop -t 10 myredis
#####################################################################
```
