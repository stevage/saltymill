###TODO call update_data to get the latest data in one hit.
osrm_update:
  file.copy:
    - name: {{ pillar['tm_osrmdir'] }}/osm.pbf
    - source: {{ pillar['tm_dir'] }}/osm.pbf
  cmd.run:
    - cwd: {{pillar['tm_osrmdir']}}
    - name: |
        build/osrm-extract extract.osm.pbf
        build/osrm-prepare extract.osrm extract.osrm.restrictions

osrm_daemon:
  cmd.run:
    - cwd: {{ pillar['tm_osrmdir'] }}
    - name: |
        nohup build/osrm-routed -i {{ grains['fqdn'] }} -p {{pillar['tm_osrmport']}} -t 8 extract.osrm > /dev/null 2>&1 & 
