#!/bin/bash
# Soal 12 - Basic auth on penny /admin (user prabs). Run on alpha AND delta.
echo "### Soal 12 @ $(hostname)"
echo "--- no credentials (expect 401 + WWW-Authenticate)"
curl -si http://www.K-49.com/admin/ | egrep 'HTTP/|WWW-Authenticate'
echo "--- wrong password (expect 401)"; curl -s -o /dev/null -w '%{http_code}\n' -u prabs:salah http://www.K-49.com/admin/
echo "--- wrong user (expect 401)";     curl -s -o /dev/null -w '%{http_code}\n' -u hacker:x http://www.K-49.com/admin/
read -rsp "password for prabs: " PW; echo
echo "--- correct login via www.K-49.com (expect page + 200)"
curl -s -w '\n%{http_code}\n' -u "prabs:$PW" http://www.K-49.com/admin/
echo "--- rest of site still open + proxied (expect 200)"; curl -s -o /dev/null -w '%{http_code}\n' http://www.K-49.com/arsip/
