#!/bin/bash
set -euo pipefail

### [0] Terraform에서 넘겨받은 Jenkins SSH 비공개 키 저장
echo "${jenkins_priv_key_b64}" | base64 -d > /tmp/jenkins_id_rsa
chmod 600 /tmp/jenkins_id_rsa

### [1] 스왑 메모리 설정
SWAP_DIR="/var/spool/swap"
SWAP_FILE="$SWAP_DIR/swapfile"

sudo mkdir -p "$SWAP_DIR"
sudo dd if=/dev/zero of="$SWAP_FILE" bs=1M count=2048
sudo chmod 600 "$SWAP_FILE"
sudo mkswap "$SWAP_FILE"
sudo swapon "$SWAP_FILE"

if ! grep -q "$SWAP_FILE" /etc/fstab; then
  echo "$SWAP_FILE none swap defaults 0 0" | sudo tee -a /etc/fstab
fi

### [2] Docker 및 필요한 도구 설치
sudo apt-get update
sudo apt-get install -y \
  ca-certificates curl gnupg lsb-release apt-transport-https git

# Docker 공식 GPG 키 등록
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null

# Docker 저장소 등록
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker 설치 (Docker 데몬 포함)
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

### [3] Dockerfile 직접 생성
echo "${dockerfile_content}" > /tmp/Dockerfile
echo "${dockercompose_content}" > /tmp/docker-compose.yml
cd /tmp
sudo docker compose up -d
sudo docker build -t custom-jenkins:gcloud .

### [4] Jenkins 컨테이너 실행
sudo docker volume create jenkins_home

sudo docker run -d \
  --name jenkins \
  -p 9090:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(getent group docker | cut -d: -f3) \
  custom-jenkins:gcloud

### [5] SSH 키 등록
while [ ! -d "/var/lib/docker/volumes/jenkins_home/_data" ]; do
  echo "Jenkins 볼륨 대기 중..."
  sleep 2
done

JENKINS_HOME="/var/lib/docker/volumes/jenkins_home/_data"

sudo mkdir -p "$JENKINS_HOME/.ssh"
sudo mv /tmp/jenkins_id_rsa "$JENKINS_HOME/.ssh/id_rsa"
sudo chmod 600 "$JENKINS_HOME/.ssh/id_rsa"
sudo chmod 700 "$JENKINS_HOME/.ssh"
sudo chown -R 1000:1000 "$JENKINS_HOME/.ssh"