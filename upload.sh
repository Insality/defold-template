#!/bin/sh

echo "Start upload"
ssh root@insality.com "rm -r /home/files/seabattle"
scp -r $1 root@insality.com:/home/files/seabattle
echo "End upload"
