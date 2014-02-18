base:
  '*':
    - initlog
    - nginx                   # Adds authentication and port sharing (only 80 exposed to the outside world)
    - tilemill                # Installs TileMill itself
    {% if defined pillar.tm_sourceurl %}
    - osm                     # PostGIS with an OpenStreetMap extract installed.
    {% if defined pillar.tm_osrminstances %}
    - osrm                    # Installs Open Source Routing Machine
    {% endif %}
    {% endif %}
    - finishlog 
