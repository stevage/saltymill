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
- OSRM (optional): Open Source Routing Machine, adds a trip routing web interface to your data.

It's a conversion of http://github.com/stevage/tilemill-server

Building a machine with the three main components takes a few minutes. Adding OSM and OSRM can take
half an hour or more, possibly much more, depending on machine configuration and extract size.

There are two ways to build a server using Salt:

1. Using a separate SaltMaster which drives the "minion" - you need two servers for this.
2. Using a "masterless minion" which drives itself.

Typical usage:


### On a clean Ubuntu Quantal VM
```
wget -O - http://bootstrap.saltstack.org | sudo sh

#*Skip the next two lines if in masterless mode* 
[ $m ] || m=INSERT.YOUR.SALTMASTER.HOSTNAME.HERE
echo master: $m | sudo tee -a /etc/salt/minion 

#Continue here for both master and masterless:

# Nginx needs to know the server's actual IP.
echo fqdn: `curl http://ifconfig.me` | sudo tee /etc/salt/grains 

sudo service salt-minion restart
```

### On the saltmaster (or the same VM if masterless):

*Skip this one step if masterless*

Install Salt, if needed:

`curl -L http://bootstrap.saltstack.org | sudo sh -s -- -M -N`

Install these scripts:
```
sudo apt-get install -y git && sudo git clone https://github.com/stevage/saltymill /srv/salt
```

Set up pillar properties:

```
sudo mkdir /srv/pillar
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
tm_dev: True                          # Install the development version of TileMill. This has newer features 
                                      # but may be less stable. No stock sample projects included.
tm_fonts:       # List of urls that provide zip downloads
  - http://www.freefontspro.com/d/12524/cartogothic_std.zip
  - http://www.fontsquirrel.com/fonts/download/roboto

# (Optional)
tm_waterpolygonsource: http://gis.researchmaps.net/water-polygons-split-3857.zip

# (Optional)
tm_projects:
                                      # Sample projects to unzip in /usr/share/mapbox/project. Name required but not used for much.
  - { name: mapstarter, source: "http://gis.researchmaps.net/sample/map-starter.zip" }
  #- { name: melbourne, source: http://gis.researchmaps.net/sample/melbourne.zip } 

                                      # OSM extract source. Comment out to skip all OSM stuff.
tm_osmsourceurl: http://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf
# For a much quicker test build, try tm_osmsourceurl: http://download.geofabrik.de/asia/azerbaijan-latest.osm.pbf

# (Optional: the Open Source Routing Machine)
# NB: OSRM instances require a lot of memory, most of which has been allocated to Postgres.
tm_osrminstances:                     # If no instances, OSRM doesn't get installed.
  - { name: Bike, port: 5010, profile: bicycle }
  - { name: Walking, port: 5011, profile: foot }
  # name: Text displayed in the OSRM web interface
  # port: The port OSRM listens on for this instances
  # profile: The included .lua file (one of car, foot, bicycle )
  # profilesource (optional, untested): URL to download a different .lua file from http://...
tm_osrmdir: /mnt/saltymill/osrm




EOF
```

*If running masterless:*

```
cd /srv/salt
sudo salt-call --local state.highstate -l info
```
*If running saltmaster:*

```
sudo service salt-master start

yes | sudo salt-key -A

sudo salt '*' state.highstate
```

### Watch it build
You can watch the progress of your server being built. Go to `http://<serverip>/saltymill`

### Using launcher.sh
If your SSH is set up so that you can connect to your minions with no arguments ("ssh mmyminion"), then you can use launcher.sh:

```
./launcher.sh minion1 minion2
# ... wait ...
ssh saltmaster "yes | salt-key"
ssh saltmaster "salt '*' state.highstate"
