#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install -y curl

echo "Node.js (Next.js 15 권장 버전인 Node.js 18 LTS) 설치"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
sudo apt-get install -y nodejs

echo "Node.js 환경 설정 완료"