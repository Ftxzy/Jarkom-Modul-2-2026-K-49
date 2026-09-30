#!/bin/bash
# Soal 11 - reverse proxies: penny -> vault (Apache), abbey -> core (Nginx). Run on alpha AND delta.
echo "### Soal 11 @ $(hostname)"
echo "--- penny (10.88.5.2) -> vault, 4 requests: should alternate obladi/desmond"
for i in 1 2 3 4; do curl -s http://10.88.5.2/arsip/contoh1.txt; done
echo "--- www.K-49.com (-> penny) headers"; curl -si http://www.K-49.com/arsip/ | egrep 'HTTP/|Server:|Index of'
echo "--- abbey (10.88.4.2) -> core, 6 requests: both oblada and molly should appear"
for i in 1 2 3 4 5 6; do curl -s http://10.88.4.2/profil | grep -o 'oleh: [a-z]*'; done
echo "--- static.K-49.com (-> abbey)"; curl -si http://static.K-49.com/ | egrep 'HTTP/|Server:|Beranda'
