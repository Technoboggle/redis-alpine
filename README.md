#####################################################################
# use the following commands to build image and upload to dockerhub #
```
#####################################################################

# Setting File permissions
xattr -c .git
xattr -c .gitignore
xattr -c .dockerignore
xattr -c *
chmod 0666 *
chmod 0777 *.sh

docker build -f Dockerfile -t technoboggle/redis-alpine:6.2.1-3.13.2 .
docker run -it -d -p 16379:6379 --rm --name myredis technoboggle/redis-alpine:6.2.1-3.13.2
docker tag technoboggle/redis-alpine:6.2.1-3.13.2 technoboggle/redis-alpine:latest
docker login
docker push technoboggle/redis-alpine:6.2.1-3.13.2
docker push technoboggle/redis-alpine:latest
docker container stop -t 10 myredis
#####################################################################
```
