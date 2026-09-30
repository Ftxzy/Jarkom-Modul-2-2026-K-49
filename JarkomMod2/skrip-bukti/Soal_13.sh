#!/bin/bash
# Soal 13 - canonical redirects. penny/IP -> 301 www ; abbey/IP -> 302 static. Run on alpha AND delta.
echo "### Soal 13 @ $(hostname)"
for u in 10.88.5.2 penny.K-49.com K-49.com; do
  echo "--- penny via $u (expect 301 -> http://www.K-49.com/...)"; curl -si http://$u/arsip/ | egrep 'HTTP/|Location:'
done
echo "--- follow the redirect"; curl -sL -o /dev/null -w '%{http_code} final=%{url_effective}\n' http://10.88.5.2/arsip/
echo "--- www.K-49.com is canonical (expect 200, no Location)"; curl -si http://www.K-49.com/arsip/ | egrep 'HTTP/|Location:'
for u in 10.88.4.2 abbey.K-49.com; do
  echo "--- abbey via $u (expect 302 -> http://static.K-49.com/...)"; curl -si http://$u/profil | egrep 'HTTP/|Location:'
done
echo "--- follow the redirect"; curl -sL -o /dev/null -w '%{http_code} final=%{url_effective}\n' http://10.88.4.2/profil
echo "--- static.K-49.com is canonical (expect 200, no Location)"; curl -si http://static.K-49.com/profil | egrep 'HTTP/|Location:'
