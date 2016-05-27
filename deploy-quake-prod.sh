#!/bin/bash

cd /home/ubuntu/

#copy in from git checkout
cp /home/ubuntu/quake/runequake-dev/autoexec-prod.cfg /home/ubuntu/quake/runequake/autoexec.cfg

#merge in password from conf file
cat rq_rcon.conf | xargs -I '{}' sed -i 's/{rcon_password}/{}/g' /home/ubuntu/quake/runequake/autoexec.cfg

cp /home/ubuntu/quake/runequake-dev/progs.dat /home/ubuntu/runequake/progs.dat