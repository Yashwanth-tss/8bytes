# Monitoring 

For the monitoring I have used the prometheus-grafana stack: 
with tools node_exporter, cadvisor, loki, grafana alloy, prometheus, grafana.

### Prometheus
Prometheus is an open-source systems monitoring and alerting toolkit. It is used to collect and store metrics as time-series data.

### Grafana
Grafana is an open-source analytics and interactive visualization web application. It provides charts, graphs, and alerts for web, file, database, cloud, and custom data sources.

### CAdvisor
CAdvisor (Container Advisor) provides container users with an understanding of the resource usage and performance characteristics of their running containers.

### Node-exporter
Node-exporter is a Prometheus exporter for exposing hardware and OS metrics.

### Loki
Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus.

### Grafana-alloy
Grafana alloy is a vendor-neutral, open-source telemetry collector for metrics, logs, and traces.

# Prometheus-Grafana-Loki stack deployment

This stack is configured as a fully automated monitoring pipeline that runs alongside your application services. Below is a detailed explanation of the architecture, configuration layout, and how to verify and interact with the stack.

---

## 1. Architecture & Telemetry Data Flow

The monitoring architecture utilizes a **push-based/forwarding collector model** managed by Grafana Alloy.

### Metrics Ingestion Flow:
1. **Node Exporter** (port `9100`) gathers host system metrics.
2. **cAdvisor** (port `8080`) gathers container resource consumption (CPU, Memory, Disk, Network) directly from the Linux slice system of the Docker daemon.
3. **Grafana Alloy** (port `8081`) scrapes the metrics endpoints of both Node Exporter and cAdvisor.
4. **Grafana Alloy** remote-writes (pushes) these metrics into **Prometheus** (port `9090`).
5. **Prometheus** acts as the metric database storage.

### Logs Ingestion Flow:
1. **Grafana Alloy** mounts the host Docker socket (`/var/run/docker.sock`).
2. It uses `discovery.docker` to list all running container metadata and streams the container stdout/stderr logs.
3. It relabels the raw container labels to human-readable names (`container="quotes-api"`).
4. Logs are pushed directly to **Loki** (port `3100`).
5. **Loki** acts as the log aggregation database storage.

---
## 2. Running & Verifying the Monitoring Stack

### Start the Stack
Navigate to monitoring directory and start the compose project in the background:
```bash
docker compose up -d
```

### Stop the Stack
```bash
docker compose down -v
```
*(The `-v` flag can be used if you need to wipe out the persistent Grafana/Prometheus database files and start fresh).*

---

## 3. Interacting with Grafana

Open your browser and navigate to: **`http://<instance-ip>:3000`**
- **Default Username**: `admin`
- **Default Password**: `admin`

### Pre-provisioned Dashboards
In the left sidebar, navigate to **Dashboards** -> **Monitoring** folder:

1. **System and Container Metrics**:
   - Displays real-time **Container CPU Usage** and **Container Memory Usage** metrics derived from cAdvisor.
   - Displays **Host CPU Usage** and **Host Memory Usage** derived from Node Exporter.
   - Features a `$container` dropdown selector allowing you to filter metrics by one or more running containers.

2. **Container Logs Dashboard**:
   - Displays a Log Rate volume graph.
   - Displays a Log Stream console displaying stdout logs.
   - Features a `$container` dropdown selector to filter logs by specific containers.
