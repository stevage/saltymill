waterpoly:
  pkg.installed:
    - names: 
       - unzip 
       - wget
  cmd.run:
    - cwd: /usr/share/mapbox
    - user: mapbox
    - group: mapbox
    - name: |
        wget -q http://gis.researchmaps.net/water-polygons-split-3857.zip  && sleep 5 && 
        unzip -o water-polygons-split-3857.zip
    - require:
        - pkg: unzip
    - unless: test -d /usr/share/mapbox/water-polygons-split-3857
