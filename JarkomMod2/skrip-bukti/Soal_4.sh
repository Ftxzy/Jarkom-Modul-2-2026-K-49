#!/bin/bash
# Soal 4 - DNS master (prab) + slave (tedd), zone K-49.com, forwarder. Run on prab, then tedd, then a client for the forwarder test.
echo "### Soal 4 @ $(hostname)"
case "$(hostname)" in
  prab|tedd)
    echo "--- named-checkconf"; named-checkconf && echo "config OK"
    echo "--- zone status"; rndc zonestatus K-49.com | egrep 'name|type|serial'
    echo "--- NS records (asked to this server)"; dig +short NS K-49.com @127.0.0.1
    echo "--- forwarders"; grep -A2 forwarders /etc/bind/named.conf.options 2>/dev/null
    ;;
esac
echo "--- NS via resolv.conf (no @)"; dig +short NS K-49.com
echo "--- tedd answers authoritatively for the zone (aa), apex and a host"
dig @10.88.3.3 K-49.com A +norecurse | egrep '^;; flags|^K-49'
dig @10.88.3.3 alpha.K-49.com A +norecurse | egrep '^;; flags|^alpha'
echo "--- forwarder: outside names via prab (prab has the forwarder to 192.168.122.1)"
dig @10.88.3.2 example.com | egrep '^;; flags|status|^example' | head -4
