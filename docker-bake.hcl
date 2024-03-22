# docker-bake.hcl
group "default" {
    targets = ["app"]
}

target "app" {
    context = "."
    dockerfile = "Dockerfile"
    tags = ["technoboggle/redis-alpine:${REDIS_VERSION}-${ALPINE_VERSION}", "technoboggle/redis-alpine:${REDIS_VERSION}", "technoboggle/redis-alpine:latest"]
    args = {
        ALPINE_VERSION = "${ALPINE_VERSION}"
        REDIS_VERSION = "${REDIS_VERSION}"
        REDIS_SHA = "${REDIS_SHA}"

        MAINTAINER = "${MAINTAINER}"
        AUTHORNAME = "${AUTHORNAME}"
        AUTHORS = "${AUTHORS}"
        VERSION = "${VERSION}"

        SCHEMAVERSION = "${SCHEMAVERSION}"
        NAME = "${NAME}"
        DESCRIPTION = "${DESCRIPTION}"
        URL = "${URL}"
        VCS_URL = "${VCS_URL}"
        VENDOR = "${VENDOR}"
        BUILDVERSION = "${BUILD_VERSION}"
        BUILD_DATE="${BUILD_DATE}"
        DOCKERCMD:"${DOCKERCMD}"
    }
    platforms = ["linux/amd64", "linux/arm64", "linux/arm64/v8", "linux/386", "linux/armhf", "linux/s390x", "linux/arm/v7", "linux/arm/v6", "linux/ppc64le"]
    push = true
    cache = false
    progress = "plain"
}
