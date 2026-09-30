#!/bin/bash
ZONE=/etc/bind/K-49/K-49.com

sed -i -E '/^abbey[[:space:]]/ s/.*/abbey  15  IN  A  10.88.4.2/' $ZONE
sed -i 's/2026093001/2026093002/' $ZONE

named-checkzone K-49.com $ZONE && rndc reload
