#!/bin/bash -x
sudo -u postgres psql -d gis <<EOF
drop table places;
create table places as
select town.name, place, town.way, 
case when place = 'locality' then 1000
when place = 'hamlet' then 2000 
when place = 'village' then 3000
when place = 'town' then 5000
when place = 'city' then 1000 end scope,
    0 pubs, 0 supermarkets, 0 cafes, 0 restaurants, 0 fuels, 0 fast_foods, 0 bakeries, 0 conveniences, 0 amenities
from planet_osm_point town where place in ('hamlet','village','town','city','locality');


update places set pubs = 
(select count(*) from planet_osm_point p where p.amenity = 'pub' and st_dwithin(p.way,places.way,scope)) +
(select count(*) from planet_osm_polygon p where p.amenity = 'pub' and st_dwithin(p.way,places.way,scope)) ;

update places set supermarkets = 
(select count(*) from planet_osm_point p where p.shop= 'supermarket' and st_dwithin(p.way,places.way,scope)) +
(select count(*) from planet_osm_polygon p where p.shop = 'supermarket' and st_dwithin(p.way,places.way,scope));

update places set cafes = 
(select count(*) from planet_osm_point p where p.amenity = 'cafe' and st_dwithin(p.way,places.way,scope)) +
(select count(*) from planet_osm_polygon p where p.amenity = 'cafe' and st_dwithin(p.way,places.way,scope));

update places set restaurants = 
(select count(*) from planet_osm_point p where p.amenity = 'restaurant' and st_dwithin(p.way,places.way,scope)) +
(select count(*) from planet_osm_polygon p where p.amenity = 'restaurant' and st_dwithin(p.way,places.way,scope));

update places set fuels = 
(select count(*) from planet_osm_point p where p.amenity = 'fuel' and st_dwithin(p.way,places.way,scope)) +
(select count(*) from planet_osm_polygon p where p.amenity = 'fuel' and st_dwithin(p.way,places.way,scope));

update places set fast_foods = 
(select count(*) from planet_osm_point p where p.amenity = 'fast_food' and st_dwithin(p.way,places.way,scope)) +
(select count(*) from planet_osm_polygon p where p.amenity = 'fast_food' and st_dwithin(p.way,places.way,scope));

update places set bakeries = 
(select count(*) from planet_osm_point p where p.shop = 'bakery' and st_dwithin(p.way,places.way,scope)) +
(select count(*) from planet_osm_polygon p where p.shop = 'bakery' and st_dwithin(p.way,places.way,scope));


update places set conveniences = 
(select count(*) from planet_osm_point p where p.shop in ( 'convenience','general') and st_dwithin(p.way,places.way,scope)) +
(select count(*) from planet_osm_polygon p where p.shop in ('convenience','general') and st_dwithin(p.way,places.way,scope));


update places
set amenities = pubs + supermarkets + cafes + restaurants + fuels + fast_foods + bakeries + conveniences;
create index idx_places on places using gist(way);

GRANT SELECT ON places TO gis;

EOF

