#!/bin/bash
./updateplaces.sh
echo "Creating simplified ways for labelling."
sudo -u postgres psql -d gis <<EOF
select waterway,name,st_simplify(way,300) simplified
into waterways
from planet_osm_line
where waterway is not null and coalesce(tunnel,'no') = 'no';

GRANT SELECT ON waterways TO gis;

EOF
echo "Calculating city distances."
#psql -d gis <<EOF
#alter table planet_osm_point add column city_distance float;
#alter table planet_osm_polygon add column city_distance float;
#update planet_osm_point a 
#set city_distance=(
#  select min(st_distance(a.way, places.way)) 
#  from places 
#  where places.place='city' and places.name in ('Melbourne','Sydney','Brisbane')) 
#where a.amenity='pub';
#
#update planet_osm_polygon a 
#set city_distance=(
#  select min(st_distance(a.way, places.way)) 
#  from places 
#  where places.place='city' and
#  places.name in ('Melbourne','Sydney','Brisbane')) 
#where a.amenity='pub';
#EOF

sudo -u postgres psql -d gis <<EOF
alter table planet_osm_point add column city_distance float;
alter table planet_osm_polygon add column city_distance float;

update planet_osm_point set city_distance=20000;
update planet_osm_point a 
set city_distance=st_distance(a.way, places.way) 
from places 
where st_dwithin(a.way, places.way, 20000.0) and coalesce(a.amenity, a.tourism) is not null and places.name='Melbourne';

update planet_osm_polygon set city_distance=20000;
update planet_osm_polygon a set city_distance=st_distance(a.way, places.way) 
from places 
where st_dwithin(a.way, places.way, 20000.0) and coalesce(a.amenity, a.tourism) is not null and places.name='Melbourne';

EOF
