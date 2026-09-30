#!/bin/bash
ZONE=/etc/bind/K-49/K-49.com

sed -i -E '/^abbey[[:space:]]/ s/.*/abbey  15  IN  A  203.0.113.77/' $ZONE
sed -i 's/2026093004/2026093005/' $ZONE

named-checkzone K-49.com $ZONE && rndc reload
