# Install water polygon shapefile. This is needed for working with OpenStreetMap data extracts.
# TODO: figure out how to make the shapefile a 'favourite'
waterpoly:
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
        wget -nv {{pillar.tm_waterpolygonsource}}  && sleep 5 && 
        unzip -o water-polygons-split-3857.zip
    - unless: test -d /usr/share/mapbox/water-polygons-split-3857 # fix this hardcoding

waterpoly_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Waterpolygon downloaded and unzipped.'"
    - watch: [ { cmd: waterpoly } ]
