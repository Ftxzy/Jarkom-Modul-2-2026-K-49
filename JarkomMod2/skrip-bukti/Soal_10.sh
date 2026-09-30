#!/bin/bash
# Soal 10 - dynamic web on core (Nginx + PHP-FPM, /profil clean URL). The doc requires testing by HOSTNAME.
# Run on alpha AND delta.
echo "### Soal 10 @ $(hostname)"
for h in oblada.K-49.com molly.K-49.com; do
  echo "--- http://$h/  (PHP home)"
  curl -si http://$h/ | egrep 'HTTP/|Server:|Beranda|Dilayani'
  echo "--- http://$h/profil  (clean URL, no .php)"
  curl -si http://$h/profil | egrep 'HTTP/|Profil|Kelompok|Dilayani'
done
echo "--- core.K-49.com resolves to both"; dig +short core.K-49.com
echo "--- core.K-49.com/profil , 4 requests"
for i in 1 2 3 4; do curl -s http://core.K-49.com/profil | grep -o 'oleh: [a-z]*'; done
