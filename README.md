SaltyMill
---------

SaltyMill uses Salt to deploy a tilemill stack on a clean Ubuntu Quantal VM. The major components are:

- TileMill: cartographic IDE for turning map data into web or static maps
-- Additional fonts
-- Sample projects
-- Waterpolygon file
- PostGIS: Postgresql database with GIS extensions, holds OpenStreetMap data
- Nginx: web server, provides password authentication and allows services to share one port (80).
- OSM (optional): extract of OpenStreetMap data downloaded and imported
- OSRM (optional): Open Source Routing Machine, a high speed routing engine indexed from the downloaded OSM extract
-- OSRMWeb: A trip routing web interface to your data that uses the OSRM backend.

It's a conversion of http://github.com/stevage/tilemill-server

Building a machine with the three main components takes a few minutes. Adding OSM and OSRM can take
half an hour or more, possibly much more, depending on machine configuration and extract size.

# Set up one VM
This is the easier way to run Salt: "masterless minion". The Salt "minion" is installed, then it drives itself to
carry out the installation.

### On a clean Ubuntu Quantal VM
```
curl -Ls http://bootstrap.saltstack.org | sudo sh
# Nginx needs to know the server's actual IP.
echo fqdn: `curl -s http://ifconfig.me` | sudo tee /etc/salt/grains > /dev/null
sudo service salt-minion restart
```

\# Install these scripts:
```
sudo apt-get install -qqy git && 
sudo git clone --quiet --depth 1 https://github.com/stevage/saltymill /srv/salt
```

\# Set up pillar properties:
```
cd /srv/salt
sudo cp -R pillar /srv/
# Edit /srv/pillar/tm.sls now. Comments are in the file.
```

\# Build!
```
sudo salt-call --local state.highstate -l info
```
### Watch it build
You can watch the progress of your server being built. Go to `http://<serverip>/saltymill`

# Set up several "minion" VMs
In this set up, multiple Salt "minions" can be set up by a single Salt Master. You will need one VM each. This is the way to go if you need to build a bunch of servers for a workshop or something. Later, you can roll out any configuration choanges: modify /srv/pillar/tm.sls on the Master, then run `salt state.highstate`.

### On each minion (clean Ubuntu Quantal VM):
```
m=INSERT.YOUR.SALTMASTER.HOSTNAME.HERE

curl -Ls http://bootstrap.saltstack.org | sudo sh
echo master: $m | sudo tee -a /etc/salt/minion 

# Nginx needs to know the server's actual IP.
echo fqdn: `curl -s http://ifconfig.me` | sudo tee /etc/salt/grains > /dev/null

sudo service salt-minion restart
```

### On the Saltmaster (any VM):

\#Install Salt:

```
curl -Ls http://bootstrap.saltstack.org | sudo sh -s -- -M -N
```

\#Install these scripts:
```
sudo apt-get install -qqy git && 
sudo git clone --quiet --depth 1 https://github.com/stevage/saltymill /srv/salt
```

\#Set up pillar properties:

```
cd /srv/salt
sudo cp -R pillar /srv/
```
\# Edit /srv/pillar/tm.sls now. Comments are in the file.

```
sudo service salt-master restart

yes | sudo salt-key -A

sudo salt '*' state.highstate
```

### Watch it build
You can watch the progress of your servers being built. Go to `http://<serverip>/saltymill` for each one.

### Using launcher.sh
If your SSH is set up so that you can connect to your minions with no arguments ("ssh myminion"), then you can use launcher.sh.
(See [this blog post](http://steveko.wordpress.com/2013/05/03/forget-trying-to-remember-your-servers-names/) for how to do that.)


```
./launcher.sh minion1 minion2
# ... wait ...
ssh saltmaster "yes | salt-key"
ssh saltmaster "salt '*' state.highstate"
```
