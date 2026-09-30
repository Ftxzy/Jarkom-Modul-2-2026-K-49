#!/bin/bash
ZONE=/etc/bind/K-49/K-49.com

cat >> $ZONE <<'REC'
alpha   IN  TXT    "alpha"
beta    IN  TXT    "beta"
gamma   IN  TXT    "gamma"
delta   IN  TXT    "delta"
epsilon IN  TXT    "epsilon"
REC

# naikkan serial 2026092803 -> 2026093001
sed -i 's/2026092803/2026093001/' $ZONE

named-checkzone K-49.com $ZONE && rndc reload
