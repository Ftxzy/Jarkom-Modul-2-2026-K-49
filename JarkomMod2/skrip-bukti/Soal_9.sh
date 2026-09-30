#!/bin/bash
# Soal 9 - static web on vault (Apache, /arsip/ autoindex). The doc requires testing by HOSTNAME, not IP.
# Run on a client: alpha AND delta.
echo "### Soal 9 @ $(hostname)"
for h in obladi.K-49.com desmond.K-49.com; do
  echo "--- http://$h/arsip/"
  curl -si http://$h/arsip/ | egrep 'HTTP/|Index of|contoh'
done
echo "--- file contents (each node shows its own name)"
curl -s http://obladi.K-49.com/arsip/contoh1.txt
curl -s http://desmond.K-49.com/arsip/contoh2.txt
echo "--- vault.K-49.com resolves to BOTH nodes"; dig +short vault.K-49.com
echo "--- vault.K-49.com/arsip/ , 4 requests (round robin by DNS)"
for i in 1 2 3 4; do curl -s http://vault.K-49.com/arsip/contoh1.txt; done
echo "--- /arsip without slash"; curl -s -o /dev/null -w '%{http_code} -> %{redirect_url}\n' http://obladi.K-49.com/arsip
