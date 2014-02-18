#!/bin/bash
# Just a quick launcher script that bootstraps a bunch of minions.
# It assumes that all keys and identity information is in your ~/.ssh/config
# You still need to manually accept the keys on the saltmaster.
if [ "$1" = "" ]; then
    echo "Usage: launcher.sh server1 server2 server3 ..."
    exit
fi
servers="$@"
for server in $servers; do

ssh $server 'cat > go.sh' <<"EOF"
wget -O - http://bootstrap.saltstack.org | sudo sh ;
echo "master: master.researchmaps.net"   | sudo tee -a /etc/salt/minion ;
echo "fqdn: `curl http://ifconfig.me`"   | sudo tee /etc/salt/grains ;
sudo service salt-minion restart ;
exit
EOF
ssh $server "bash ./go.sh" & > /tmp/${server}.out

done
