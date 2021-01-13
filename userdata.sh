#!/bin/bash

apt update
apt install -y nginx

set -e

export DEBIAN_FRONTEND=noninteractive

# region Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
# endregion

# region Launch containers

# Run the load generator
docker run -d \
  --restart=always \
  -p 8080:8080 \
  quay.io/janoszen/http-load-generator:1.0.1