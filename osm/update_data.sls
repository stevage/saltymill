# Download latest OpenStreetMap extract and import it.

###TODO: What to do if another import process is underway? Test for this? Kill it? Kill ourselves?
include: [ .get_data, .postgis ]

install_at:
  pkg.installed:
    - name: at


do_import:
  cmd.wait:
    # All of this mess is about preventing the import holding up the whole deployment.
    - name: echo './import.sh > import.log && ./process.sh >> import.log' | at now +1 minute
    - cwd: {{pillar['tm_dir']}}
    - user: root
    - group: root
    - watch: [ cmd: update_data ] # Only import if we have fresh .pbf
    - require: [ pkg: install_at, sls: osm.postgis ]

osmimport_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Loading OSM data with OSM2PGSQL in background.'"
    - watch: [ cmd: do_import ]        
