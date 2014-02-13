update_data:
  cmd.run:
    - cwd: {{ pillar['tm_dir'] }}
    - name: |
        rm -f australia-latest.osm.pbf
        echo --- Downloading data.
        #wget -q http://download.geofabrik.de/openstreetmap/australia-oceania/australia-latest.osm.pbf
        wget -q {{ pillar['tm_osmsourceurl'] }} 
        #TODO allow update if file more than 24 hours old.
    - unless: test -f {{ pillar['tm_dir'] }}/*.pbf 

do_import:
  cmd.run:
#    - name: | 
#        {{pillar['tm_dir']}}/import.sh
#        {{pillar['tm_dir']}}/process.sh
    - name: nohup bash -c './import.sh && ./process.sh ' &
    - cwd: {{pillar['tm_dir']}}
    - user: ubuntu
    - group: ubuntu
    - require: [ pkg: install_postgis_pkgs ]
    - watch: [ cmd: update_data ] # Only import if we have fresh .pbf
