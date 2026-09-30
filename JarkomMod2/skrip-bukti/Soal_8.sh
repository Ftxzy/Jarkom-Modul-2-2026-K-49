#!/bin/bash
# Soal 8 - reverse zone / PTR for abbey, penny, vault, core. Run on alpha AND delta.
echo "### Soal 8 @ $(hostname)"
for ip in 10.88.4.2 10.88.5.2 10.88.3.4 10.88.3.5 10.88.3.6 10.88.3.7; do
  printf '%-10s -> %s\n' $ip "$(dig +short -x $ip)"
done
echo "--- authoritative PTR (aa flag) from slave tedd, then master prab, no recursion"
for ns in 10.88.3.3 10.88.3.2; do
  echo "[@$ns]"; dig @$ns -x 10.88.4.2 +norecurse | egrep '^;; flags|PTR\s'
  dig @$ns -x 10.88.3.6 +norecurse | egrep '^;; flags|PTR\s'
done
