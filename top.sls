base:
  '*':
    - initlog
    - nginx                   # Adds authentication and port sharing (only 80 exposed to the outside world)
    - tilemill                # Installs TileMill itself
    - osm
    - osrm                  # Installs Open Source Routing Machine
    - finishlog 
    #'roles:tilemill':
    #- match: grain
    #'roles:osm':
    #- match: grain
    #'roles:osrm':
    #- match: grain
