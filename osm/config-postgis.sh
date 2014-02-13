source ./getspecs.sh
source ./tm-settings

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
