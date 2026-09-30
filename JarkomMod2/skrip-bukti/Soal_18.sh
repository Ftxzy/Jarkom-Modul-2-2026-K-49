#!/bin/bash
# Soal 18 - TTL experiment proof, phase queries. Run on alpha ONLY (needs its local BIND cache on 127.0.0.1).
# Usage: ./Soal_18.sh before | cached | expired | final     (see README "Soal 18" for the order and timing)
Q="dig abbey.K-49.com @127.0.0.1 +noall +answer +comments"
case "$1" in
  before)  rndc flush; echo "first query after a flush may SERVFAIL, repeat until an answer shows"; $Q | egrep 'status|IN.A' ;;
  cached)  echo "--- alpha cache (should still show the OLD/real IP, TTL counting down)"; $Q | egrep 'status|IN.A'
           echo "--- prab directly (already the fake IP)"; dig abbey.K-49.com @10.88.3.2 +noall +answer ;;
  expired) echo "--- alpha cache after the TTL ran out (now the fake IP)"; $Q | egrep 'status|IN.A' ;;
  final)   rndc flush; echo "--- normal resolver, no @ (must be the real IP, TTL 604800)"; dig +noall +answer abbey.K-49.com
           dig +noall +answer static.K-49.com; curl -s -o /dev/null -w 'static.K-49.com/profil -> %{http_code}\n' http://static.K-49.com/profil ;;
  *) echo "usage: $0 before|cached|expired|final"; exit 1 ;;
esac
