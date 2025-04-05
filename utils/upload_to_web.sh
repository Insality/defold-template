#!/bin/sh

echo "Start upload"
ssh root@insality.com "rm -r /home/files/rocket_dash"
scp -r $1 root@insality.com:/home/files/rocket_dash
echo "End upload"
