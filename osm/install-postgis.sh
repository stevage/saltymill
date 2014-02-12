#!/bin/bash
#Install PostGIS and OSM2PGSQL, and tune the former for available memory.

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi 

source ../getspecs.sh
source ../tm-settings


#As per https://github.com/gravitystorm/openstreetmap-carto
apt-get install -y policykit-1 postgresql-9.1 libpq-dev postgis
# Check to make sure we haven't already run this.
if [ -n "$POSTGRESDIR" ] && [ ! -d "$POSTGRESDIR/postgresql" ]; then sudo bash <<FOF
echo Moving postgresql from /var/lib/postgresql to $POSTGRESDIR/postgresql

mkdir -p $POSTGRESDIR
service postgresql stop
cd /var/lib/
mv postgresql $POSTGRESDIR
ln -s $POSTGRESDIR/postgresql postgresql
chmod a+r $POSTGRESDIR
service postgresql start
FOF
fi

# Install OSM2pgsql
apt-get install -y software-properties-common git unzip
add-apt-repository -y ppa:kakrueger/openstreetmap
apt-get update

# what if I skip this line?
###TODO
export DEBIAN_FRONTEND=noninteractive
apt-get install -y osm2pgsql

# Configure Postgres
# Argh - can't crack the right combination here. I give up in the end and just make ubuntu a superuser. Just needs
# to be able to modify the 'relation' spatial_ref_sys
sudo -E -u postgres psql <<FOF
CREATE ROLE $tm_dbusername WITH LOGIN CREATEDB UNENCRYPTED PASSWORD '$tm_dbpassword';
GRANT ALL ON SCHEMA public TO $tm_dbusername;
GRANT ALL ON ALL TABLES IN SCHEMA public TO $tm_dbusername;
ALTER USER $tm_dbusername WITH SUPERUSER;
FOF


# create GIS template
db=template_gis
sudo -E -su postgres bash <<EOF
createdb --encoding=UTF8 --owner=$tm_dbusername $db
psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='$db'"

psql -d $db -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql > /dev/null
psql -d $db -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql > /dev/null
psql -d $db -f /usr/share/postgresql/9.1/contrib/postgis_comments.sql > /dev/null
psql -d $db -c "GRANT SELECT ON spatial_ref_sys TO PUBLIC;"
psql -d $db -c "GRANT ALL ON geometry_columns TO $tm_dbusername;"
psql -d $db -c "create extension hstore;"
EOF

sudo -E -u postgres createdb --template=$db gis

sudo -E -u postgres psql -d gis -c "GRANT ALL ON DATABASE gis TO $tm_dbusername;"


echo "Configure Postgres for performance, given ${MYMEM} GB of RAM."
sudo tee -a /etc/postgresql/9.1/main/postgresql.conf <<FOF
# Settings tuned for TileMill
shared_buffers = $((MYMEM/4))GB
autovacuum = on
effective_cache_size = $((MYMEM/4))GB
work_mem = 128MB
maintenance_work_mem = 64MB
wal_buffers = 1MB

FOF

echo "Set Postgres to start automatically in /etc/rc.local"
sudo tee /etc/rc.local <<FOF
#!/bin/sh -e
sysctl -w kernel.shmmax=$((MYMEM/4 + 1))000000000
sysctl -w kernel.shmall=$((MYMEM/4 + 1))000000000
service postgresql start
start tilemill
service nginx start
exit 0
FOF

#sudo bash /etc/rc.local
#sudo service postgresql reload
