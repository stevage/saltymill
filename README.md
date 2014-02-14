SaltyMill
---------

This is a rough salt configuration to deploy a tilemill stack (including nginx, postgres, and OSM data).
It's a conversion of http://github.com/stevage/tilemill-server

Typical usage:

### On the saltmaster:

*If needed:* 

`curl -L http://bootstrap.saltstack.org | sudo sh -s -- -M -N`

```
sudo tee /srv/pillar/top.sls <<EOF
base:
  '*':
    - tm
EOF
sudo tee /srv/pillar/tm.sls <<EOF
tm_username: tm                       # Username/password for basic htpasswd authentication
tm_password: pumpkin                   
tm_dbusername: ubuntu                 # Postgres username/password that will be created
tm_dbpassword: ubuntu                 # and used to load data with. It doesn't get external access.
tm_postgresdir: /mnt/var/lib          # Directory to move Postgres to (ie, big, non-ephemeral drive).
tm_timezone: 'Australia/Melbourne'    # We set the timezone because NeCTAR VMs don't have it set.
tm_dir: /mnt/saltymill                # Where to install scripts to.
                                      # Where to download OSM extracts from.
tm_osmsourceurl: http://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf

# (If using OSRM)
tm_osrmdir: /mnt/saltymill/osrm
tm_osrmport: 5010
tm_osrmprofile: bicycle

EOF

sudo service salt-master start
```
### On a clean VM
```
wget -O - http://bootstrap.saltstack.org | sudo sh

sudo tee -a /etc/salt/minion <<EOF
master: *INSERT YOUR SALTMASTER IP/FQDN HERE*
grains:
  fqdn: `curl http://ifconfig.me` # Nginx needs to know the server's actual IP.
  roles:
    - tilemill
    - osm                         # Remove the osm role to skip hosting a local OSM database.
EOF

sudo salt-minion -d
```
### On the master again
```
sudo salt-key -A

sudo salt '*' state.highstate
```