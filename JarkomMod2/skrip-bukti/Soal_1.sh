#!/bin/bash
# Soal 1 - IP address + gateway. Run on ANY node (alpha, prab, rootkit, ...)
echo "### Soal 1 @ $(hostname)"
echo "--- hostname"; hostname
echo "--- IP addresses"; ip -br -4 a | grep -v '^lo'
echo "--- default gateway"; ip route | grep default || echo "(no default route!)"
GW=$(ip route | awk '/default/{print $3; exit}')
echo "--- ping gateway $GW"; ping -c2 -W2 "$GW"
