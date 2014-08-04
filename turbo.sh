#!/bin/bash
# Usage: turbo.sh [noedit]

echo Turbo installer for SaltyMill
echo "127.0.0.1 salt # Required to shut salt up (see https://github.com/saltstack/salt/issues/10466)" | sudo tee -a /etc/hosts
sudo apt-get install -qq curl
which salt-call || curl -Ls http://bootstrap.saltstack.org | sudo sh
echo "fqdn: $(curl -s http://ifconfig.me)" | sudo tee /etc/salt/grains > /dev/null
sudo service salt-minion  stop # No need for minion to be running?

# FIXME: Ensures apt-get succeeded before cloning, but if one or the
# other fails, the rest of the script will fail too. Handle this better.
sudo apt-get install -qq git-core &&
  sudo -E git clone --quiet --branch "${branch:-stable}" --depth 1 https://github.com/stevage/saltymill /srv/salt

# FIXME: Why not just use /srv/salt/pillar rather than 'cd'?
cd /srv/salt || exit 1
sudo cp -R pillar /srv/

if [[ $1 != noedit ]]; then
  echo You should edit /srv/pillar/tm.sls now. Comments are in the file.
  echo Type \"skip\" to skip or anything else to edit.
  echo
  echo Or ^C now, then later:
  echo
  echo sudo salt-call --local state.highstate
  read -r text
  if [[ $text != skip ]]; then
    sudo pico /srv/pillar/tm.sls
  fi
fi
sudo salt-call --local state.highstate -l info
