#!/bin/bash
set -eux

sudo apt update

# docker 설치
sudo apt install -y \
  ca-certificates curl gnupg lsb-release apt-transport-https git

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo chmod 666 /var/run/docker.sock

mkdir -p /home/peter/monitoring
cd /home/peter/monitoring
echo "${dockercompose_content}" > docker-compose.yml
echo "${prometheus_content}" > prometheus.yml
echo "${loki_content}" > loki.yml
echo "${thanosgcs_content}" > thanos-gcs.yml
echo "${endpoints_content}" > endpoints.yml

mkdir -p loki-data
mkdir -p grafana-data
mkdir -p prometheus-data
mkdir -p thanos-store-data

sudo chmod -R 0777 loki-data
sudo chmod -R 0777 grafana-data
sudo chmod -R 0777 prometheus-data
sudo chmod -R 0777 thanos-store-data

docker compose up -d