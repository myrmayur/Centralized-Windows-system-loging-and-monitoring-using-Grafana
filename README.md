# Grafana Monitoring and Logging Setup

This repository provides detailed documentation on setting up a Grafana server for monitoring and logging various systems and services, including Asterisk server, KVM, Fortigate, Windows, and SageMaker. This setup uses Prometheus, Loki, Promtail, and Winlogbeat to collect and visualize metrics and logs.

## Table of Contents

- [Introduction](#introduction)
- [System Overview](#system-overview)
- [Installation and Configuration](#installation-and-configuration)
  - [Grafana Server](#grafana-server)
  - [Prometheus](#prometheus)
  - [Loki](#loki)
  - [Promtail](#promtail)
  - [Winlogbeat](#winlogbeat)
- [Data Sources Configuration in Grafana](#data-sources-configuration-in-grafana)
  - [Adding Prometheus as a Data Source](#adding-prometheus-as-a-data-source)
  - [Adding Loki as a Data Source](#adding-loki-as-a-data-source)
  - [Adding Elasticsearch as a Data Source](#adding-elasticsearch-as-a-data-source)
- [Dashboards and Visualizations](#dashboards-and-visualizations)
  - [Creating Dashboards](#creating-dashboards)
  - [Customizing Panels](#customizing-panels)
- [Alerts Configuration](#alerts-configuration)
  - [Setting Up Alerts for SageMaker](#setting-up-alerts-for-sagemaker)
  - [Setting Up Alerts for Other Services](#setting-up-alerts-for-other-services)


## Introduction

### Purpose
This document provides a detailed guide on setting up a Grafana server for monitoring and logging various systems and services, including Asterisk server, KVM, Fortigate, Windows, and SageMaker.

### Scope
This document covers the installation, configuration, and integration of Grafana with Prometheus, Loki, Promtail, and Winlogbeat, along with the configuration of data sources, dashboards, and alerts in Grafana.

## System Overview

### Architecture Diagram
![image](https://github.com/myrmayur/Centralized-Windows-system-loging-and-monitoring-using-Grafana/blob/main/grafana%20architecture.png?raw=true)
### Components
- **Grafana Server:** The central monitoring and visualization platform.
- **Prometheus:** Used for scraping and storing metrics from Asterisk and KVM.
- **Loki:** Used for aggregating logs.
- **Promtail:** Used for shipping logs to Loki.
- **Winlogbeat:** Used for collecting logs from Windows machines.

## Installation and Configuration

### Grafana Server

#### Installation Steps
1. Download Grafana:
   ```sh
   wget https://dl.grafana.com/oss/release/grafana-8.0.0.linux-amd64.tar.gz
   ```
2. Install Grafana:
   ```sh
   tar -zxvf grafana-8.0.0.linux-amd64.tar.gz
   cd grafana-8.0.0
   ./bin/grafana-server
   ```
3. Start and enable Grafana service:
   ```sh
   sudo systemctl start grafana-server
   sudo systemctl enable grafana-server
   ```

#### Configuration
- Access the Grafana UI at `http://your_server_ip:3000`.
- Login with the default credentials (`admin`/`admin`) and change the password.

### Prometheus

#### Installation Steps
1. Download Prometheus:
   ```sh
   wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz
   ```
2. Install Prometheus:
   ```sh
   tar -zxvf prometheus-2.26.0.linux-amd64.tar.gz
   cd prometheus-2.26.0.linux-amd64
   ./prometheus
   ```

#### Configuration
- Configure Prometheus to scrape metrics from Asterisk and KVM by editing the `prometheus.yml` file:
  ```yaml
  scrape_configs:
    - job_name: 'asterisk'
      static_configs:
        - targets: ['asterisk_server_ip:port']
    - job_name: 'kvm'
      static_configs:
        - targets: ['kvm_server_ip:port']
  ```

### Loki

#### Installation Steps
1. Download Loki:
   ```sh
   wget https://github.com/grafana/loki/releases/download/v2.2.1/loki-linux-amd64.zip
   unzip loki-linux-amd64.zip
   ```
2. Install Loki:
   ```sh
   chmod +x loki-linux-amd64
   ./loki-linux-amd64
   ```

#### Configuration
- Configure Loki by editing the `loki-local-config.yaml` file:
  ```yaml
  auth_enabled: false

  server:
    http_listen_port: 3100

  ingester:
    lifecycler:
      ring:
        kvstore:
          store: inmemory
        replication_factor: 1
      final_sleep: 0s
    chunk_idle_period: 5m
    chunk_retain_period: 30s
    max_transfer_retries: 0
  schema_config:
    configs:
      - from: 2020-10-24
        store: boltdb
        object_store: filesystem
        schema: v11
        index:
          prefix: index_
          period: 168h
  storage_config:
    boltdb:
      directory: /tmp/loki/index

    filesystem:
      directory: /tmp/loki/chunks

  limits_config:
    enforce_metric_name: false
    reject_old_samples: true
    reject_old_samples_max_age: 168h
  ```

### Promtail

#### Installation Steps
1. Download Promtail:
   ```sh
   wget https://github.com/grafana/loki/releases/download/v2.2.1/promtail-linux-amd64.zip
   unzip promtail-linux-amd64.zip
   ```
2. Install Promtail:
   ```sh
   chmod +x promtail-linux-amd64
   ./promtail-linux-amd64
   ```

#### Configuration
- Configure Promtail by editing the `promtail-local-config.yaml` file:
  ```yaml
  server:
    http_listen_port: 9080
    grpc_listen_port: 0

  positions:
    filename: /tmp/positions.yaml

  clients:
    - url: http://localhost:3100/loki/api/v1/push

  scrape_configs:
    - job_name: system
      static_configs:
        - targets:
            - localhost
          labels:
            job: varlogs
            __path__: /var/log/*log
  ```

### Winlogbeat

#### Installation Steps
1. Download Winlogbeat:
   ```sh
   curl -L -O https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.10.0-windows-x86_64.zip
   ```
2. Install Winlogbeat:
   ```sh
   unzip winlogbeat-7.10.0-windows-x86_64.zip
   cd winlogbeat-7.10.0-windows-x86_64
   install-service-winlogbeat.ps1
   ```

#### Configuration
- Configure Winlogbeat by editing the `winlogbeat.yml` file:
  ```yaml
  winlogbeat.event_logs:
    - name: Application
      ignore_older: 72h
    - name: Security
  output.elasticsearch:
    hosts: ["http://localhost:9200"]
  ```

## Data Sources Configuration in Grafana

### Adding Prometheus as a Data Source
1. Navigate to **Configuration** > **Data Sources** in Grafana.
2. Click **Add data source**.
3. Select **Prometheus**.
4. Enter the Prometheus URL (`http://localhost:9090`) and click **Save & Test**.

### Adding Loki as a Data Source
1. Navigate to **Configuration** > **Data Sources** in Grafana.
2. Click **Add data source**.
3. Select **Loki**.
4. Enter the Loki URL (`http://localhost:3100`) and click **Save & Test**.

### Adding Elasticsearch as a Data Source
1. Navigate to **Configuration** > **Data Sources** in Grafana.
2. Click **Add data source**.
3. Select **Elasticsearch**.
4. Enter the Elasticsearch URL (`http://localhost:9200`) and click **Save & Test**.

## Dashboards and Visualizations

### Creating Dashboards
1. Navigate to **Dashboards** > **New Dashboard** in Grafana.
2. Add a new panel and select the desired data source.
3. Configure the visualization as needed.

### Customizing Panels
1. Customize the panels by selecting the appropriate metrics or logs.
2. Use Grafana's query editor to fine-tune the data displayed.
3. Save the dashboard.

## Alerts Configuration

### Setting Up Alerts for SageMaker
1. Create a new alert rule in the desired dashboard panel.
2. Define the alert conditions and thresholds.
3. Configure notifications (e.g., email, Slack).

### Setting Up Alerts for Other Services
1. Follow similar steps to set up alerts for Asterisk, KVM, Fortigate,
