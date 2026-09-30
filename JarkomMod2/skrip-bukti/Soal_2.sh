#!/bin/bash
# Soal 2 - NAT + forwarding. Run on rootkit (config), then on a client (alpha/delta) for end-to-end proof.
echo "### Soal 2 @ $(hostname)"
if [ "$(hostname)" = "rootkit" ]; then
  echo "--- ip_forward"; sysctl net.ipv4.ip_forward
  echo "--- NAT rule"; iptables -t nat -S POSTROUTING
  echo "--- interfaces"; ip -br -4 a | grep -v '^lo'
else
  echo "--- ping internet by IP (via rootkit NAT)"; ping -c3 -W3 8.8.8.8
fi
