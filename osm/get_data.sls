update_data:
  cmd.run:
    - cwd: {{ pillar['tm_dir'] }}
    - name: |
        rm -f extract.osm.pbf
        echo --- Downloading data.
        wget -nv {{ pillar['tm_osmsourceurl'] }} -O extract.osm.pbf
        # Hmm, no way to know if download failed.
        touch extract.osm.pbf    # we want to know the date we received the file, not the age of its content. 
        # fetch data only if there is none newer than 6 hours old around.
    - unless:  test "`find {{ pillar['tm_dir']}} -maxdepth 0 -iname extract.osm.pbf -mmin -360`"

osmgetdata_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: '"OSM data downloaded."'
    - watch: [ cmd: update_data ]        

test "`find /mnt/saltymill -iname extract.osm.pbf -mmin -360`"