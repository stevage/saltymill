#!/bin/bash
wget {{ pillar.tm_osmsourceurl }} -O extract.osm.pbf
./osrm-extract extract.osm.pbf
./osrm-prepare extract.osrm
pkill -f 'osrm-routed.*-p {{ port }}'
./start-osrm.sh