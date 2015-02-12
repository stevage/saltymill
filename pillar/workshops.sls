# This settings file is used for "Mapping for academics" workshops.
tm_osmsourceurl: http://gis.researchmaps.net/australia-latest.osm.pbf

tm_projects: # Sample projects to unzip in /usr/share/mapbox/project.
  - { name: mapstarter, source: "http://gis.researchmaps.net/sample/map-starter.zip" }
  - { name: melbourne, source: "http://gis.researchmaps.net/sample/melbourne.zip" }

tm_username: tm
tm_password: resbaz

# Prevent a few things being installed that we don't need.
tm_osrminstances: [] # If no instances, OSRM doesn't get installed.
tm_demdir: ''
tm_tilestreamport:''
