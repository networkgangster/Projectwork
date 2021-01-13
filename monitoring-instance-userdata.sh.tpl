#!/bin/bash

# Abort on all errors
set -e

#This is not production grade, but for the sake of brevity we are using it like this.
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Create shared directory for service discovery config
mkdir -p /srv/service-discovery/
chmod a+rwx /srv/service-discovery/

# Write Prometheus config
cat <<EOCF >/srv/prometheus.yml
global:
  scrape_interval: 30s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'exoscale'
    file_sd_configs:
      - files:
          - /srv/service-discovery/config.json
        refresh_interval: 10s
EOCF

#prometheus json
cat <<EOCF >/srv/service-discovery/config.json
[{"target":[],"labels":{}}]
EOCF

chmod a+rwx /srv/service-discovery/config.json

# Create the network
docker network create monitoring

# Run service discovery agent
docker run \
    -d \
    --name sd \
    --network monitoring \
    -v /srv/service-discovery:/var/run/prometheus-sd-exoscale-instance-pools \
    quay.io/janoszen/prometheus-sd-exoscale-instance-pools:1.0.0 \
    --exoscale-api-key ${exoscale_key} \
    --exoscale-api-secret ${exoscale_secret} \
    --exoscale-zone-id ${exoscale_zone_id} \
    --instance-pool-id ${instance_pool_id}

# Run Prometheus
docker run -d \
    -p 9090:9090 \
    --name prometheus \
    --network monitoring \
    -v /srv/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v /srv/service-discovery/:/srv/service-discovery/ \
    prom/prometheus