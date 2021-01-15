#!/bin/bash

apt update
apt install -y nginx

# Stop if error occurs
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

# Run the node exporter
docker run -d \
  --restart=always \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter \
  --path.rootfs=/host