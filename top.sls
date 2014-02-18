base:
  '*':
    - initlog
    - nginx                   # Adds authentication and port sharing (only 80 exposed to the outside world)
    - tilemill                # Installs TileMill itself
    {% if pillar.tm_osmsourceurl is defined %}
    - osm                     # PostGIS with an OpenStreetMap extract installed.
    {% if pillar.tm_osrminstances is defined %}
    - osrm                    # Installs Open Source Routing Machine
    {% endif %}
    {% endif %}
    - finishlog 
