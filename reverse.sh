#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
sleep 10
sshpass -p 'password' ssh -N -R 10027:127.0.0.1:22 user@server_IP
