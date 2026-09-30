#!/bin/bash
for URL in http://www.K-49.com/ http://static.K-49.com/; do
  echo "=============================="
  echo "Benchmark: $URL"
  echo "=============================="
  ab -n 250 -c 10 $URL | grep -E "Server Hostname|Document Path|Concurrency Level|Time taken|Complete requests|Failed requests|Non-2xx|Requests per second|Time per request|Transfer rate"
done
