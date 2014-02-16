# Download latest OpenStreetMap extract and import it.

###TODO: What to do if another import process is underway? Test for this? Kill it? Kill ourselves?
update_data:
  cmd.run:
    - cwd: {{ pillar['tm_dir'] }}
    - name: |
        rm -f extract.osm.pbf
        echo --- Downloading data.
        wget -q {{ pillar['tm_osmsourceurl'] }} -O extract.osm.pbf
        touch extract.osm.pbf    # we want to know the date we received the file, not the age of its content. 
        # fetch data only if there is none newer than 6 hours old around.
    - unless:  test `find {{ pillar['tm_dir']}} -iname extract.osm.pbf -mmin -360`

osmgetdata_logdone:
  cmd.wait:
    - name: echo "OSM data downloaded.<br/>" >> /var/log/salt/buildlog.html
    - watch: [ cmd: update_data ]        


do_import:
  cmd.wait:
    # All of this mess is about preventing the import holding up the whole deployment.
    - name: echo './import.sh && ./process.sh' | at now +1 minute
    - cwd: {{pillar['tm_dir']}}
    - user: ubuntu
    - group: ubuntu
    - watch: [ cmd: update_data ] # Only import if we have fresh .pbf

osmimport_logdone:
  cmd.wait:
    - name: echo "Loading OSM data with OSM2PGSQL in background.<br/>" >> /var/log/salt/buildlog.html
    - watch: [ cmd: do_import ]        
