#!/bin/bash
# Soal 3 - Internal routing + early resolver. Run on alpha (left wing) AND delta (right wing).
echo "### Soal 3 @ $(hostname)"
echo "--- /etc/resolv.conf"; cat /etc/resolv.conf
for t in 10.88.1.2 10.88.1.3 10.88.1.4 10.88.2.2 10.88.2.3 10.88.3.2 10.88.3.3 10.88.3.4 10.88.3.6 10.88.4.2 10.88.5.2 192.168.122.1; do
  ping -c1 -W2 $t >/dev/null 2>&1 && echo "OK    $t" || echo "FAIL  $t"
done
OTHER=10.88.2.2; [ "$(hostname)" = "delta" ] && OTHER=10.88.1.2
echo "--- path to other wing ($OTHER)"; ip route get $OTHER | head -1; traceroute -n -w1 -m3 $OTHER 2>/dev/null || tracepath -n -m3 $OTHER 2>/dev/null | head -4
