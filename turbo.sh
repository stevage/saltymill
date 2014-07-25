#!/bin/bash
# Usage: turbo.sh [noedit]

echo Turbo installer for SaltyMill
echo "127.0.0.1 salt # Required to shut salt up (see https://github.com/saltstack/salt/issues/10466)" | sudo tee -a /etc/hosts
sudo apt-get install -y curl
which salt-call || curl -Ls http://bootstrap.saltstack.org | sudo sh
echo fqdn: `curl -s http://ifconfig.me` | sudo tee /etc/salt/grains > /dev/null
sudo service salt-minion restart

sudo apt-get install -qqy git-core && 
sudo -E git clone --quiet --branch ${branch:-stable} --depth 1 https://github.com/stevage/saltymill /srv/salt

cd /srv/salt
sudo cp -R pillar /srv/

if [ "$1" == "noedit" ]; then
sudo salt-call --local state.highstate -l info
exit 0;
fi

echo "You should edit /srv/pillar/tm.sls now. Comments are in the file."
echo Type "skip" to skip or anything else to edit. 
echo 
echo Or ^C now, then later: 
echo 
echo salt-call --local statehighstate
read text
if [ "$text" != "skip" ]; then
sudo pico /srv/pillar/tm.sls
fi
sudo salt-call --local state.highstate -l info