base:
  '*':
    # - logging # Doesn't work well, and causes node issues.
    - initlog
    - nginx                   # Adds authentication and port sharing (only 80 exposed to the outside world)
    - tilemill                # Installs TileMill itself
    # Currently logic requires full PostGIS extract/build even if we just want the extract for OSRM.
    {% if pillar.tm_osmsourceurl is defined %} 
    - osm                     # PostGIS with an OpenStreetMap extract installed.
    {% if pillar.tm_osrminstances is defined %}
    - osrm                    # Installs Open Source Routing Machine
    {% endif %}
    {% endif %}
    {% if pillar.tm_tilestreamport is defined %}
    - tilestream              # Installs TileStream
    {% endif %}
    {% if pillar.tm_demdir is defined %}
    - dems                    # Installs some digital elevation models (DEMs)
    {% endif %}
    - finishlog 
