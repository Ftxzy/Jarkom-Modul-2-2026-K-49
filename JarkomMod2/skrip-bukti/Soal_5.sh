#!/bin/bash
# Soal 5 - hostnames + A record per node. Run on a client (alpha, then delta).
echo "### Soal 5 @ $(hostname)"
for h in rootkit alpha beta gamma delta epsilon prab tedd obladi desmond oblada molly abbey penny; do
  printf '%-8s -> %s\n' $h "$(dig +short $h.K-49.com | tr '\n' ' ')"
done
echo "--- apex"; printf 'K-49.com -> %s\n' "$(dig +short K-49.com)"
