#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "▶ 시스템 패키지 업데이트"
sudo apt-get update -y
sudo apt-get install -y curl

echo "▶ Node.js (Next.js 15 권장 버전인 Node.js 18 LTS) 설치"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
sudo apt-get install -y nodejs

echo "▶ Node.js 환경 설정 완료"

echo "▶ Docker 설치 시작"
sudo apt-get install -y \
    ca-certificates curl gnupg lsb-release apt-transport-https

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
sudo apt-get install -y google-cloud-sdk google-cloud-sdk-artifact-registry-credential-helper

echo "▶ peter 계정 Docker Credential Helper 구성"
sudo mkdir -p /home/peter/.docker
sudo tee /home/peter/.docker/config.json > /dev/null <<EOF
{
  "credHelpers": {
    "asia-northeast3-docker.pkg.dev": "gcloud"
  }
}
EOF
sudo chown -R peter:peter /home/peter/.docker

echo "▶ root 계정에도 동일한 docker config 복사"
sudo mkdir -p /root/.docker
sudo cp /home/peter/.docker/config.json /root/.docker/config.json

echo "▶ peter 계정에 docker 그룹 권한 부여"
sudo usermod -aG docker peter

echo "✅ startup.sh 완료"