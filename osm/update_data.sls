# Download latest OpenStreetMap extract and import it.

update_data:
  cmd.run:
    - cwd: {{ pillar['tm_dir'] }}
    - name: |
        rm -f osm.pbf
        echo --- Downloading data.
        wget -q {{ pillar['tm_osmsourceurl'] }} -O extract.osm.pbf
        touch {{ extract.osm.pbf }}   # we want to know the date we received the file, not the age of its content. 
        # fetch data only if there is none newer than 6 hours old around.
    - unless:  test `find {{ pillar['tm_dir']}} -iname extract.pbf -mmin -360`

do_import:
  cmd.wait:
    # All of this mess is about preventing the import holding up the whole deployment.
    - name: echo './import.sh && ./process.sh' | at now +1 minute
    - cwd: {{pillar['tm_dir']}}
    - user: ubuntu
    - group: ubuntu
    - watch: [ cmd: update_data ] # Only import if we have fresh .pbf
