base:
  '*':
    - initlog
  {% if pillar['roles:tilemill'] is not defined %}
  #'roles:tilemill':
    - match: grain
    - nginx                   # Adds authentication and port sharing (only 80 exposed to the outside world)
    - tilemill                # Installs TileMill itself
    - tilemill.fonts          # Grabs useful fonts (just CartoGothic for the momen)
    - tilemill.waterpolygons  # Grabs OSM waterpolygon shapefile
  {% endif %}
  {% if grains['roles:osm'] is not defined %}
  #'roles:osm':
    - match: grain
    - osm.postgis           # Installs PostGIS and moves it if needed
    - osm.osm2pgsql         # Installs OSM2PGSQL, configures for subsequent reloading
    - osm.update_data      # Fetches and imports OSM data
  {% endif %}
  {% if grains['roles:osrm'] is not defined %}
  #'roles:osrm':
    - match: grain
    - osrm                  # Installs Open Source Routing Machine
    - osrm.osrmweb
    - osrm.update_osrm      # Builds the OSRM routing index
  {% endif %}
