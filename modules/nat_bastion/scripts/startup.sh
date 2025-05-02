#!/bin/bash
set -eux

# 기본 경로 인터페이스 자동 추출 (8.8.8.8로 가는 경로 기준)
NAT_INTERFACE=$(ip route get 8.8.8.8 2>/dev/null \
  | awk '/dev/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}')
: "${NAT_INTERFACE:=ens4}"   # 추출 실패 시 ens4 사용

echo ">>> Using NAT interface: $NAT_INTERFACE"

# 비대화형으로 iptables-persistent 설치 준비
export DEBIAN_FRONTEND=noninteractive
sudo debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF

echo ">>> Updating system packages..."
sudo apt-get update

echo ">>> Installing iptables-persistent package..."
sudo apt-get install -y iptables-persistent

# IP 포워딩 활성화 & 재부팅 시 유지
echo ">>> Enabling IP forwarding..."
sudo sed -i 's@#\?net.ipv4.ip_forward=.*@net.ipv4.ip_forward=1@' /etc/sysctl.conf
sudo sysctl -p

# iptables NAT 룰 추가
echo ">>> Setting up iptables NAT rules on interface: $NAT_INTERFACE..."
sudo iptables -t nat -A POSTROUTING -o "$NAT_INTERFACE" -j MASQUERADE

# 룰 저장 및 서비스 활성화
echo ">>> Saving iptables rules..."
sudo iptables-save | sudo tee /etc/iptables/rules.v4

echo ">>> Enabling & starting netfilter-persistent service..."
sudo systemctl enable netfilter-persistent
sudo systemctl start  netfilter-persistent

echo ">>> NAT instance setup complete!"
