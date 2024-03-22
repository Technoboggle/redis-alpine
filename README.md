[![Known Vulnerabilities](https://snyk.io/test/github/Technoboggle/redis-alpine/badge.svg)](https://snyk.io/test/github/Technoboggle/redis-alpine)

[![Technoboggle Rules](https://img.shields.io/badge/technoboggle-rules-f08060)]

[![Docker Automated Build](https://img.shields.io/github/automated/technoboggle/redis-alpine?icon=docker&label=automated_build)]
[![Docker Build Status](https://img.shields.io/github/last-commit/technoboggle/redis-alpine?icon=docker&label=build_status)]
[![Docker Pulls](https://badgen.net/docker/pulls/technoboggle/redis-alpine?icon=docker&label=pulls)](https://hub.docker.com/r/technoboggle/redis-alpine/)
[![Docker Stars](https://badgen.net/docker/stars/technoboggle/redis-alpine?icon=docker&label=stars)](https://hub.docker.com/r/technoboggle/redis-alpine/)
[![Docker Image Size](https://badgen.net/docker/size/technoboggle/redis-alpine?icon=docker&label=image%20size)](https://hub.docker.com/r/technoboggle/redis-alpine/)

![Github stars](https://badgen.net/github/stars/technoboggle/redis-alpine?icon=github&label=stars)
![Github forks](https://badgen.net/github/forks/technoboggle/redis-alpine?icon=github&label=forks)
![Github issues](https://img.shields.io/github/issues/technoboggle/redis-alpine)
![Github last-commit](https://img.shields.io/github/last-commit/technoboggle/redis-alpine)


# Redis Alpine

This repository contains code to build a container image for Redis using Alpine Linux as the base image.

## Prerequisites

- Docker: [Install Docker](https://docs.docker.com/get-docker/)

## Getting Started

To retrieve and run a container based on the images created by the code in this repository, follow these steps:

1. Clone the repository:

    ```bash
    git clone https://github.com/Technoboggle/redis-alpine.git
    ```

2. Build the Docker image:

    ```bash
    docker build -t redis-alpine .
    ```

3. Run the Docker container:

    ```bash
    docker run -d --name redis-container redis-alpine
    ```

## License

This project is licensed under the [MIT License](LICENSE).