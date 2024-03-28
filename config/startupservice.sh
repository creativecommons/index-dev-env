#!/bin/bash

/sbin/apache2ctl -v
echo 'Starting webserver: http://127.0.0.1:8080'
# Start Apache in the foreground
/sbin/apache2ctl -D FOREGROUND -k start
