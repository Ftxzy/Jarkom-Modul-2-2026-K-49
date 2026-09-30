#!/bin/bash
# Soal 6 - zone transfer, serials match. Run on prab or tedd (or any client).
echo "### Soal 6 @ $(hostname)"
echo "--- SOA master (prab)"; dig +short SOA K-49.com @10.88.3.2
echo "--- SOA slave  (tedd)"; dig +short SOA K-49.com @10.88.3.3
echo "--- reverse zone serials"
dig +short SOA 88.10.in-addr.arpa @10.88.3.2
dig +short SOA 88.10.in-addr.arpa @10.88.3.3
echo "--- AXFR from tedd (allowed only for slave)"
[ "$(hostname)" = "tedd" ] && dig AXFR K-49.com @10.88.3.2 | egrep 'SOA|Transfer|XFR' | head -5
echo "--- slave data file present"; [ "$(hostname)" = "tedd" ] && ls -l /var/cache/bind/
echo "--- tedd answers authoritatively (aa) for both zones"
dig @10.88.3.3 K-49.com SOA +norecurse | egrep '^;; flags|IN\s+SOA'
dig @10.88.3.3 88.10.in-addr.arpa SOA +norecurse | egrep '^;; flags|IN\s+SOA'
