#!/bin/bash

# Stop if error occurs
set -e

# source: https://fh-cloud-computing.github.io/exercises/3-containers/
# Install docker
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

# write service discovery config
cat <<EOCF >/srv/service-discovery/config.json
[{"target":[],"labels":{}}]
EOCF

chmod a+rwx /srv/service-discovery/config.json

# Create shared directory for grafana datasources
mkdir -p /srv/grafana/provisioning/datasources/
chmod a+rwx /srv/grafana/provisioning/datasources/

# source: https://fh-cloud-computing.github.io/exercises/5-grafana/
# write data source config
cat <<EOCF >/srv/grafana/provisioning/datasources/prom.yml
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  orgId: 1
  url: http://prometheus:9090
  version: 1
  editable: false
EOCF

# Create shared directory for grafana notifiers
mkdir -p /srv/grafana/provisioning/notifiers/
chmod a+rwx /srv/grafana/provisioning/notifiers/

#source: https://fh-cloud-computing.github.io/exercises/5-grafana/
# write notifier config
cat <<EOCF >/srv/grafana/provisioning/notifiers/notifiers.yml
notifiers:
  - name: Scale up
    type: webhook
    uid: FG1mrWBMk
    org_id: 1
    is_default: false
    send_reminder: true
    disable_resolve_message: true
    frequency: "5m"
    settings:
      autoResolve: true
      httpMethod: "POST"
      severity: "critical"
      uploadImage: false
      url: "http://autoscaler:8090/up"
  - name: Scale down
    type: webhook
    uid: cMhOCZBGz
    org_id: 1
    is_default: false
    send_reminder: true
    disable_resolve_message: true
    frequency: "5m"
    settings:
      autoResolve: true
      httpMethod: "POST"
      severity: "critical"
      uploadImage: false
      url: "http://autoscaler:8090/down"
EOCF

# Create shared directory for grafana dashboard config
mkdir -p /srv/grafana/provisioning/dashboards/
chmod a+rwx /srv/grafana/provisioning/dashboards/

# source: https://fh-cloud-computing.github.io/exercises/5-grafana/
# write dashboard config
cat <<EOCF >/srv/grafana/provisioning/dashboards/dashboard.yml
apiVersion: 1

providers:
- name: 'Home'
  orgId: 1
  folder: ''
  type: file
  updateIntervalSeconds: 10
  options:
    path: /etc/grafana/dashboards
EOCF

# Create shared directory for grafana dashboard
mkdir -p /srv/grafana/dashboards/
chmod a+rwx /srv/grafana/dashboards/

# write dashboard json
cat <<EOCF >/srv/grafana/dashboards/dashboard.json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": 1,
  "links": [],
  "panels": [
    {
      "alert": {
        "alertRuleTags": {},
        "conditions": [
          {
            "evaluator": {
              "params": [
                0.8
              ],
              "type": "gt"
            },
            "operator": {
              "type": "and"
            },
            "query": {
              "params": [
                "A",
                "1m",
                "now"
              ]
            },
            "reducer": {
              "params": [],
              "type": "avg"
            },
            "type": "query"
          }
        ],
        "executionErrorState": "alerting",
        "for": "1m",
        "frequency": "1m",
        "handler": 1,
        "name": "highCPU",
        "noDataState": "no_data",
        "notifications": [
          {
            "uid": "FG1mrWBMk"
          }
        ]
      },
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 2,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.3.7",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "avg(\r\n    sum by (instance) (rate(node_cpu_seconds_total{mode!=\"idle\"}[1m])) /\r\n    sum by (instance) (rate(node_cpu_seconds_total[1m]))\r\n)",
          "interval": "",
          "legendFormat": "",
          "queryType": "randomWalk",
          "refId": "A"
        }
      ],
      "thresholds": [
        {
          "colorMode": "critical",
          "fill": true,
          "line": true,
          "op": "gt",
          "value": 0.8
        }
      ],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Panel Title",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "decimals": 1,
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": "1",
          "min": "0",
          "show": true
        },
        {
          "decimals": 1,
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": "1",
          "min": "0",
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "alert": {
        "alertRuleTags": {},
        "conditions": [
          {
            "evaluator": {
              "params": [
                0.2
              ],
              "type": "lt"
            },
            "operator": {
              "type": "and"
            },
            "query": {
              "params": [
                "A",
                "1m",
                "now"
              ]
            },
            "reducer": {
              "params": [],
              "type": "avg"
            },
            "type": "query"
          }
        ],
        "executionErrorState": "alerting",
        "for": "1m",
        "frequency": "1m",
        "handler": 1,
        "name": "lowCPU",
        "noDataState": "no_data",
        "notifications": [
          {
            "uid": "cMhOCZBGz"
          }
        ]
      },
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "hiddenSeries": false,
      "id": 3,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.3.7",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "avg(\r\n    sum by (instance) (rate(node_cpu_seconds_total{mode!=\"idle\"}[1m])) /\r\n    sum by (instance) (rate(node_cpu_seconds_total[1m]))\r\n)",
          "interval": "",
          "legendFormat": "",
          "queryType": "randomWalk",
          "refId": "A"
        }
      ],
      "thresholds": [
        {
          "colorMode": "critical",
          "fill": true,
          "line": true,
          "op": "lt",
          "value": 0.2
        }
      ],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Panel Title",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "decimals": 1,
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": "1",
          "min": "0",
          "show": true
        },
        {
          "decimals": 1,
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": "1",
          "min": "0",
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    }
  ],
  "schemaVersion": 26,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "sprint3",
  "uid": "HzrJKGfMz",
  "version": 2
}
EOCF

# Create the network
docker network create monitoring

# source: https://github.com/FH-Cloud-Computing/sprint-2/
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

# source: https://github.com/FH-Cloud-Computing/sprint-2/
# Run Prometheus
docker run -d \
    -p 9090:9090 \
    --name prometheus \
    --network monitoring \
    -v /srv/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v /srv/service-discovery/:/srv/service-discovery/ \
    prom/prometheus

# Run Grafana
docker run -d \
    -p 3000:3000 \
    --name grafana \
    --network monitoring \
    -v /srv/grafana/provisioning/datasources/prom.yml:/etc/grafana/provisioning/datasources/prom.yml \
    -v /srv/grafana/provisioning/notifiers/notifiers.yml:/etc/grafana/provisioning/notifiers/notifiers.yml \
    -v /srv/grafana/provisioning/dashboards/dashboard.yml:/etc/grafana/provisioning/dashboards/dashboard.yml \
    -v /srv/grafana/dashboards/dashboard.json:/etc/grafana/dashboards/dashboard.json \
    grafana/grafana

# source: https://github.com/janoszen/exoscale-grafana-autoscaler
# Run autoscaler
sudo docker run -d \
    -p 8090:8090 \
    --name autoscaler \
    --network monitoring \
    janoszen/exoscale-grafana-autoscaler:1.0.2 \
    --exoscale-api-key ${exoscale_key} \
    --exoscale-api-secret ${exoscale_secret} \
    --exoscale-zone-id ${exoscale_zone_id} \
    --instance-pool-id ${instance_pool_id}