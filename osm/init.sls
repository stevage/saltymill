{{pillar['tm_dir']}}:
  file.directory:
    - group: ubuntu
    - user: ubuntu
    - mode: 755
    - makedirs: True

{{pillar['tm_dir']}}/tm-settings:
  file.managed:
    - source: salt://osm/tm-settings
    - template: jinja
    - user: ubuntu
    - group: ubuntu
    - mode: 744

{{pillar['tm_dir']}}/getspecs.sh:
  file.managed:
    - source: salt://osm/getspecs.sh
    - template: jinja
    - user: ubuntu
    - group: ubuntu
    - mode: 744

include:
    - .postgres         # Installs PostGres and moves it if needed
    - .postgis          # Installs PostGIS and creates template database
    - .osm2pgsql        # Installs OSM2PGSQL, configures for subsequent reloading
    - .update_data      # Fetches and imports OSM data
