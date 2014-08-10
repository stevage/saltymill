# Install water polygon shapefile. This is needed for working with OpenStreetMap data extracts.
# TODO: figure out how to make the shapefile a 'favourite'
extrafiles:
  pkg.installed:
    - names: 
       - unzip 
       - wget
  cmd.run:
    - cwd: /usr/share/mapbox
    - user: mapbox
    - group: mapbox
    - require:
        - pkg: unzip
    - name: |
        {% for f in pillar.tm_tilemillextras %}
        wget -nv {{ f }}
        {% endfor %}
        sleep 5
        yes no | unzip '*.zip' # Don't overwrite any existing files
        unzip -f '*.zip' # Freshen existing files if needed
    # - unless: test -d /usr/share/mapbox/water-polygons-split-3857 # should we bother trying to not repeat?

extrafiles_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Extra tilemill files downloaded and unzipped.'"
    - watch: [ { cmd: extrafiles } ]
