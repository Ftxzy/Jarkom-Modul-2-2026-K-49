#!/bin/sh
# Soal 20: rebuild whatever a project reopen wiped (background; log in /root/boot.log)
service bind9 start
/root/soal20_tedd.sh >> /root/boot.log 2>&1 &
