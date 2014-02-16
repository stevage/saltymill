base:
  '*':
    - initlog
    #'roles:tilemill':
    #- match: grain
    - nginx                   # Adds authentication and port sharing (only 80 exposed to the outside world)
    - tilemill                # Installs TileMill itself
    #'roles:osm':
    #- match: grain
    - osm.postgis           # Installs PostGIS and moves it if needed
    - osm.osm2pgsql         # Installs OSM2PGSQL, configures for subsequent reloading
    - osm.update_data      # Fetches and imports OSM data
    #'roles:osrm':
    #- match: grain
    - osrm                  # Installs Open Source Routing Machine
    
