#!/bin/bash

cp /home/ubuntu/quake/runequake-dev/progs.dat /home/ubuntu/runequake/progs.dat
screen -S quake_server -p 0 -X stuff "changelevel start$(printf \\r)"