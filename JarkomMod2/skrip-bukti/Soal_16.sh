#!/bin/bash
# Soal 16 - ApacheBench from alpha: -n 250 -c 10 on www.K-49.com and static.K-49.com. Run on alpha ONLY.
# Needs ab: apt-get update && apt-get install -y apache2-utils   (wiped after a project reopen)
echo "### Soal 16 @ $(hostname)"; which ab || { echo "ab missing, install apache2-utils first"; exit 1; }
for URL in http://www.K-49.com/ http://static.K-49.com/; do
  echo "=============================="; echo "Benchmark: $URL"; echo "=============================="
  ab -n 250 -c 10 $URL 2>&1 | grep -E "Server Hostname|Document Path|Concurrency Level|Time taken|Complete requests|Failed requests|Length:|Non-2xx|Requests per second|Time per request|Transfer rate"
done
# Extra (teammate's report used -l for static: accept variable response length, so oblada/molly's 1-byte difference is not counted as a failure)
echo "=============================="; echo "Benchmark: http://static.K-49.com/  (with -l)"; echo "=============================="
ab -l -n 250 -c 10 http://static.K-49.com/ 2>&1 | grep -E "Concurrency Level|Time taken|Complete requests|Failed requests|Requests per second"
