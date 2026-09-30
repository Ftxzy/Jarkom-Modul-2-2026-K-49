#!/bin/bash
ZONE=/etc/bind/K-49/K-49.com

sed -i -E '/^abbey[[:space:]]/ s/.*/abbey  IN  A  10.88.4.2/' $ZONE
sed -i 's/2026093005/2026093006/' $ZONE

named-checkzone K-49.com $ZONE && rndc reload
