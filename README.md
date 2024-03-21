# Redis Alpine

[![Build Status](https://img.shields.io/travis/your-username/redis-alpine.svg)](https://travis-ci.org/your-username/redis-alpine)
[![Snyk Vulnerabilities](https://img.shields.io/snyk/vulnerabilities/github/your-username/redis-alpine.svg)](https://snyk.io/test/github/your-username/redis-alpine)

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