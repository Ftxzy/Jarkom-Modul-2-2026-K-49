#!/bin/bash
# Soal 7 - vault/core A records, www/static CNAME. Run on alpha AND delta.
echo "### Soal 7 @ $(hostname)"
for n in vault core; do echo "--- $n"; dig +short $n.K-49.com; done
for n in www static; do echo "--- $n (CNAME chain)"; dig +noall +answer $n.K-49.com; done
echo "--- authoritative answers (aa flag) straight from master and slave, no recursion"
for ns in 10.88.3.2 10.88.3.3; do
  echo "[@$ns]"; dig @$ns vault.K-49.com +norecurse | egrep '^;; flags|^vault'
  dig @$ns www.K-49.com +norecurse | egrep '^;; flags|CNAME'
done
