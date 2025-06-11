#!/bin/bash
set -euo pipefail
trap 'echo "[ERROR] 에러 발생 위치: 라인 $LINENO"; exit 1' ERR

# [1] 스왑 메모리 설정
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

# [2] Docker 및 GCloud CLI 설치
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https git

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

sudo apt-get update
sudo apt-get install -y google-cloud-cli

# [3] Jenkins 컨테이너 볼륨 준비 및 백업 복원
sudo docker volume create jenkins_home
sudo docker run --rm -v jenkins_home:/data busybox true

JENKINS_HOME="/var/lib/docker/volumes/jenkins_home/_data"

LATEST_BACKUP=$(gsutil ls gs://backup-dolpin-k8s/jenkins-backups/ | sort | tail -n 1)

touch /tmp/restore.lock

(
  trap 'rm -f /tmp/restore.lock' EXIT
  if [ -z "$LATEST_BACKUP" ]; then
    echo "INFO: 백업 파일이 존재하지 않습니다. Jenkins를 초기 상태로 시작합니다."
  else
    gsutil cp "$LATEST_BACKUP" /tmp/jenkins_backup_latest.tar.gz
    sudo mkdir -p "$JENKINS_HOME"
    sudo tar -xvzf /tmp/jenkins_backup_latest.tar.gz --strip-components=2 -C "$JENKINS_HOME"
    sudo chown -R 1000:1000 "$JENKINS_HOME"
  fi
) &

while [ -f /tmp/restore.lock ]; do
  sleep 1
done

# [5] Jenkins + node-exporter 컨테이너 실행
echo "${dockerfile_content}" > /tmp/Dockerfile
echo "${dockercompose_content}" > /tmp/docker-compose.yml
cd /tmp
export DOCKER_GID=$(getent group docker | cut -d: -f3)
DOCKER_GID="$DOCKER_GID" docker compose up -d