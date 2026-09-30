#!/bin/bash
# Soal 14 - backends log the REAL client IP, not the proxy IP. Two steps.
# STEP 1: run this on alpha AND delta (sends requests through both proxies, tagged with this node's name).
# STEP 2: read the logs on the four backends (commands printed at the end).
TAG=$(hostname)-$(date +%H%M%S)
echo "### Soal 14 @ $(hostname)  tag=$TAG  my IP=$(hostname -I)"
for i in 1 2 3 4; do
  curl -s -o /dev/null "http://www.K-49.com/arsip/contoh1.txt?tag=$TAG"
  curl -s -o /dev/null "http://static.K-49.com/profil?tag=$TAG"
done
echo "sent 8 requests. Now, on each backend, run (expect the client IP above, NOT 10.88.5.2 / 10.88.4.2):"
echo "  obladi, desmond : grep 'tag=$TAG' /var/log/apache2/access.log | awk '{print \$1, \$7}'"
echo "  oblada, molly   : grep 'tag=$TAG' /var/log/nginx/access.log   | awk '{print \$1, \$7}'"
