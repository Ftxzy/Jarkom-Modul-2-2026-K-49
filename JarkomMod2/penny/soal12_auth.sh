#!/bin/bash
apt-get install -y apache2-utils
htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
