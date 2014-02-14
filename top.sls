base:
  'roles:tilemill':
    - match: grain
    - tilemill              # Installs TileMill itself
    - nginx                 # Adds authentication and port sharing (only 80 exposed to the outside world)
    - fonts                 # Grabs useful fonts (just CartoGothic for the momen)
    - waterpolygons         # Grabs OSM waterpolygon shapefile
  'roles:osm':
    - match: grain
    - osm.postgis           # Installs PostGIS and moves it if needed
    - osm.osm2pgsql         # Installs OSM2PGSQL, configures for subsequent reloading
    # - osm.update_data      # Fetches and imports OSM data

  'roles:osrm':
    - match: grain
    - osrm.init                 # Installs Open Source Routing Machine
    - osrm.update_data      # Builds the OSRM routing index
