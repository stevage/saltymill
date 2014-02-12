update_data:
  cmd.run:
    - cwd: {{ grains['tm_dir'] }}
    - name: |
        rm -f australia-latest.osm.pbf
        echo --- Downloading data.
        #wget -q http://download.geofabrik.de/openstreetmap/australia-oceania/australia-latest.osm.pbf
        wget -q http://gis.researchmaps.net/australia-latest.osm.pbf

do_import:
  cmd.run:
    - name: {{grains['tm_dir']}}/import.sh
    - cwd: {{grains['tm_dir']}}
    - user: ubuntu
    - group: ubuntu
    - require: [ cmd: install_postgis ]

do_process:
  cmd.run:
    - name: {{grains['tm_dir']}}/process.sh
    - cwd: {{grains['tm_dir']}}
    - user: ubuntu
    - group: ubuntu
    - require: [ cmd: install_postgis ]
