#!/bin/bash
set -e

exec > /var/log/startup-script.log 2>&1

# Docker 설치
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

# Docker GPG 키 및 repository 설정
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu jammy stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Docker 서비스 활성화
systemctl enable docker
systemctl start docker

# InfluxDB 1.8 컨테이너 실행
docker run -d \
  --name influxdb \
  -p 8086:8086 \
  -v /var/lib/influxdb:/var/lib/influxdb \
  influxdb:1.8

# InfluxDB 초기화 대기 후 DB 생성
sleep 10
docker exec influxdb influx -execute "CREATE DATABASE k6"