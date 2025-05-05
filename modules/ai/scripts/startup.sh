#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "시스템 패키지 업데이트 및 업그레이드"
apt-get update -y
apt-get upgrade -y

echo "Python 및 필수 도구 설치"
apt-get install -y python3 python3-pip python3-venv git