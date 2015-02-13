#!/bin/bash
wget {{ pillar.tm_osmsourceurl }} -O extract.osm.pbf
./osrm-extract extract.osm.pbf
./osrm-prepare extract.osrm
./start-osrm.sh