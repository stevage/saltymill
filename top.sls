base:
  'roles:tilemill':
    - tilemill
    - nginx
    - fonts
    - waterpolygons
  'roles:osm':
    - osm.install_postgis