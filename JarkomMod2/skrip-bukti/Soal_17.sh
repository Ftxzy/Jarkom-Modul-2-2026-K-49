#!/bin/bash
# Soal 17 - TXT records: each client returns its own hostname. Run on alpha AND delta.
echo "### Soal 17 @ $(hostname)"
for h in alpha beta gamma delta epsilon; do
  printf '%-8s TXT -> ' $h; dig +short TXT $h.K-49.com | tr '\n' ' '; echo
done
echo "--- same answer from the slave (tedd) = zone transferred"; dig +short TXT epsilon.K-49.com @10.88.3.3
echo "--- serial on master and slave (must be equal; 2026093001 right after item 17, 2026093007 in the final state)"
dig +short SOA K-49.com @10.88.3.2 | awk '{print "prab:", $3}'
dig +short SOA K-49.com @10.88.3.3 | awk '{print "tedd:", $3}'
echo "--- A records still fine"; dig +short alpha.K-49.com
