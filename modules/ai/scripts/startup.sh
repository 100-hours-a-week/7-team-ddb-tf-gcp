#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "▶ 시스템 패키지 업데이트"
sudo apt-get update -y

echo "▶ 필수 도구 설치"
sudo apt-get install -y \
    python3 python3-pip python3-venv git \
    ca-certificates curl gnupg lsb-release apt-transport-https

echo "▶ Docker 설치"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "▶ Google Cloud SDK 설치"
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    gpg --dearmor | sudo tee /usr/share/keyrings/cloud.google.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y google-cloud-sdk

echo "▶ peter 계정에 docker 그룹 권한 부여"
sudo usermod -aG docker peter

echo "▶ docker compose 실행"
cd /tmp
echo "${dockercompose_content}" > /tmp/docker-compose.yml

sudo docker compose up -d

echo "✅ startup.sh 완료"