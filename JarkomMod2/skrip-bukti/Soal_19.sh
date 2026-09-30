#!/bin/bash
# Soal 19 - outbound.K-49.com CNAME -> http.badssl.com ; curl content must match badssl. Run on alpha AND delta.
echo "### Soal 19 @ $(hostname)"
echo "--- DNS: CNAME chain"; dig +noall +answer outbound.K-49.com
echo "--- same answer from the slave (tedd)"; dig +short outbound.K-49.com @10.88.3.3
echo "--- plain curl (Host: outbound.K-49.com): badssl's server may show its DEFAULT page"
curl -s -m 15 -i http://outbound.K-49.com/ | egrep -i 'HTTP/|<title'
echo "--- curl with Host: http.badssl.com (the page badssl actually serves for that name)"
curl -s -m 15 -i -H 'Host: http.badssl.com' http://outbound.K-49.com/ | egrep -i 'HTTP/|<title'
echo "--- body identical to the real site? (two identical md5 = match)"
curl -s -m 15 -H 'Host: http.badssl.com' http://outbound.K-49.com/ | md5sum
curl -s -m 15 http://http.badssl.com/ | md5sum
