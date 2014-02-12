update_data:
  cmd.run:
    - cwd: {{ grains['tm_dir'] }}
    - name: |
      rm -f australia-latest.osm.pbf
      echo --- Downloading data.
      #wget -q http://download.geofabrik.de/openstreetmap/australia-oceania/australia-latest.osm.pbf
      wget -q http://gis.researchmaps.net/australia-latest.osm.pbf

{{grains['tm_dir']}}/import.sh:
  cmd.run:
    - cwd: {{grains['tm_dir']}}
    - user: ubuntu
    - group: ubuntu
    - require: [ cmd: install_postgis ]

{{grains['tm_dir']}}/process.sh:
  cmd.run:
    - cwd: {{grains['tm_dir']}}
    - user: ubuntu
    - group: ubuntu
    - require: [ cmd: install_postgis ]
