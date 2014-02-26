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

include: {% if pillar.tm_dbusername is defined %}
    - .postgres         # Installs PostGres and moves it if needed
    - .postgis          # Installs PostGIS and creates template database    
    - .osm2pgsql        # Installs OSM2PGSQL, configures for subsequent reloading {% endif %}
    - .get_data         # Fetch new data (useful for OSRM, even if PostGIS is out.
    {% if pillar.tm_dbusername is defined %}
    - .update_data      # Fetches and imports OSM data
    {% endif %}
