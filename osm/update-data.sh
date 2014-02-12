#!/bin/bash
rm -f australia-latest.osm.pbf
echo --- Downloading data.
#wget -q http://download.geofabrik.de/openstreetmap/australia-oceania/australia-latest.osm.pbf
wget -q http://gis.researchmaps.net/australia-latest.osm.pbf
echo "--- Start importing into PostGIS"
./import.sh
echo "--- Start updating place table."
#./updateplaces.sh
./process.sh
#echo "--- Now updating OSRM routing tables."
#mv australia-latest.osm.pbf osrm
#./updateosrm.sh
