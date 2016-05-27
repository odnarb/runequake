#!/bin/bash

cd /home/ubuntu/quake/runequake-dev
rm src/map-auto.qc
git checkout src/*.qc
git pull
cat /home/ubuntu/rq_rcon.conf | xargs -I '{}' sed -i 's/{rcon_password}/{}/g' autoexec.cfg
cd src
cat /home/ubuntu/rq_passcode.conf | xargs -I '{}' sed -i 's/{admin_passcode}/{}/g' settings.qc
make
rc=$?
if [ $rc -ne 0 ]; then
    echo "RuneQuake compile FAILED..exiting"
    exit
fi
cd ../
cp progs.dat ../
screen -S dev_server -p 0 -X stuff "changelevel start$(printf \\r)"