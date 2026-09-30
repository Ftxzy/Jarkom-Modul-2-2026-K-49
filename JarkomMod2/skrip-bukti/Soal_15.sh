#!/bin/bash
# Soal 15 - penny /eternal (PHP-capable, served locally) and abbey /orion (static only). Run on alpha AND delta.
echo "### Soal 15 @ $(hostname)"
echo "--- penny /eternal/ : PHP must EXECUTE (output shows PHP version, no '<?php' source)"
curl -si http://www.K-49.com/eternal/ | egrep 'HTTP/|Eternal|<\?php'
echo "--- penny /eternal/index.php"; curl -s http://www.K-49.com/eternal/index.php; echo
echo "--- abbey /orion/ : static page"
curl -si http://static.K-49.com/orion/ | egrep 'HTTP/|Server:|Orion'
echo "--- bare /orion (no slash): doc needs it; expect 301 -> /orion/ then 200"
curl -si http://static.K-49.com/orion | egrep 'HTTP/|Location:'
curl -sL -o /dev/null -w '%{http_code} final=%{url_effective}\n' http://static.K-49.com/orion
echo "--- abbey has no PHP: a .php under /orion/ is not executed (expect 404)"
curl -s -o /dev/null -w '%{http_code}\n' http://static.K-49.com/orion/x.php
echo "--- other paths unaffected (expect 200 200 401)"
curl -s -o /dev/null -w '%{http_code} ' http://www.K-49.com/arsip/
curl -s -o /dev/null -w '%{http_code} ' http://static.K-49.com/profil
curl -s -o /dev/null -w '%{http_code}\n' http://www.K-49.com/admin/
