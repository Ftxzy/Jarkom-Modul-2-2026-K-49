#!/bin/bash
ZONE=/etc/bind/K-49/K-49.com
sed -i 's/^abbey[[:space:]].*/abbey   15  IN  A   203.0.113.77/' $ZONE
S=$(grep -oP '\d{10}(?=\s*; Serial)' $ZONE)
sed -i "s/$S/$((S+1))/" $ZONE
named-checkzone K-49.com $ZONE && rndc reload
echo "Perubahan dilakukan pada: $(date +%T)"
