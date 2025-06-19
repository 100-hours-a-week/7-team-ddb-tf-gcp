#!/bin/bash
set -e

# 시스템 패키지 업데이트
apt-get update
apt-get install -y gnupg2 curl ca-certificates software-properties-common

# k6 GPG 키 및 저장소 등록 (Ubuntu 22.04 대응)
curl -fsSL https://dl.k6.io/key.gpg | gpg --dearmor -o /usr/share/keyrings/k6.gpg
echo "deb [signed-by=/usr/share/keyrings/k6.gpg] https://dl.k6.io/deb stable main" \
    > /etc/apt/sources.list.d/k6.list

# k6 설치
apt-get update
apt-get install -y k6

# 설치 검증 로그
echo "k6 installed at $(which k6)" > /var/log/k6-install.log
k6 version >> /var/log/k6-install.log