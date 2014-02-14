source ./getspecs.sh
source ./tm-settings

if psql gis -c '' 2>/dev/null; then 
    # If database already exists, then exit with no output so salt knows this script did nothing.
    # Well that's the theory. Doesn't seem to like it.
    echo "changed=no"
    exit 0
fi

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
template=template_gis
sudo -E -su postgres <<EOF
createdb --encoding=UTF8 --owner=$tm_dbusername $template --template=template0
psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='$template'"

psql -d $template -f /usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql > /dev/null
psql -d $template -f /usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql > /dev/null
psql -d $template -f /usr/share/postgresql/9.1/contrib/postgis_comments.sql > /dev/null
psql -d $template -c "GRANT SELECT ON spatial_ref_sys TO PUBLIC;"
psql -d $template -c "GRANT ALL ON geometry_columns TO $tm_dbusername;"
psql -d $template -c "CREATE EXTENSION hstore;"
EOF

sudo -E -u postgres createdb --template=$template gis
sudo -E -u postgres psql -d gis -c "GRANT ALL ON DATABASE gis TO $tm_dbusername;"
