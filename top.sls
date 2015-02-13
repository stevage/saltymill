base:
  '*':
    # - logging # Doesn't work well, and causes node issues.
    - initlog
    - nginx                   # Adds authentication and port sharing (only 80 exposed to the outside world)
    - tilemill                # Installs TileMill itself
    # Currently logic requires full PostGIS extract/build even if we just want the extract for OSRM.
    {% if pillar.tm_osmsourceurl is defined and pillar.tm_osmsourceurl  %} 
    - osm                     # PostGIS with an OpenStreetMap extract installed.
    {% if pillar.tm_osrminstances is defined and pillar.tm_osrminstances %}
    - osrm                    # Installs Open Source Routing Machine
    {% endif %}
    {% endif %}
    {% if pillar.tm_tilestreamport is defined and pillar.tm_tilestreamport%}
    - tilestream              # Installs TileStream
    {% endif %}
    {% if pillar.tm_demdir is defined and pillar.tm_demdir%}
    - dems                    # Installs some digital elevation models (DEMs)
    {% endif %}
    - finishlog 
