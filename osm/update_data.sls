update_data:
  cmd.run:
    - cwd: {{ pillar['tm_dir'] }}
    - name: |
        rm -f australia-latest.osm.pbf
        echo --- Downloading data.
        #wget -q http://download.geofabrik.de/openstreetmap/australia-oceania/australia-latest.osm.pbf
        wget -q {{ pillar['tm_osmsourceurl'] }}
        touch {{ pillar['tm_osmsourceurl'] }}   # we want to know the date we received the file, not the age of its content. 
        # fetch data only if there is none newer than 6 hours old around.
    - unless:  test `find {{ pillar['tm_dir']}} -iname '*.pbf' -mmin -360`

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
      # import only if file is less than 6 hours old.
    #ifonly:  test `find {{ pillar['tm_dir']}} -iname '*.pbf' -mmin -360`
