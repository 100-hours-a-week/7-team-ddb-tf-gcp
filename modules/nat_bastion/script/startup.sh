#!/bin/bash

# NAT 인터페이스 이름 (기본값: enp3s0, 필요 시 수정하거나 인자로 전달)
NAT_INTERFACE=${1:-enp3s0}

echo ">>> Updating system packages..."
sudo apt update

echo ">>> Installing iptables-persistent package..."
sudo apt install -y iptables-persistent
systemctl start iptables
systemctl enable iptables

echo ">>> Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
fi

echo ">>> Setting up iptables NAT rules on interface: $NAT_INTERFACE..."
sudo iptables -t nat -A POSTROUTING -o "$NAT_INTERFACE" -j MASQUERADE

echo ">>> Saving iptables rules..."
sudo iptables-save | sudo tee /etc/iptables/rules.v4

echo ">>> Starting and enabling iptables service..."
sudo systemctl enable netfilter-persistent
sudo systemctl start netfilter-persistent

echo ">>> NAT instance setup complete!"
