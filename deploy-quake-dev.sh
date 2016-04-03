#!/bin/bash

cd /home/ubuntu/quake/runequake-dev
git pull
cd src
make
cd ../
cp progs.dat ../
screen -S dev_server -p 0 -X stuff "changelevel start$(printf \\r)"