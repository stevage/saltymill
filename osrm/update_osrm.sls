###TODO call update_data to get the latest data in one hit.
osrm_update:
  file.copy:
    - name: {{ pillar['tm_osrmdir'] }}/extract.osm.pbf
    - source: {{ pillar['tm_dir'] }}/extract.osm.pbf
  cmd.wait:
    - cwd: {{pillar['tm_osrmdir']}}
    - name: |
        build/osrm-extract extract.osm.pbf
        build/osrm-prepare extract.osrm
        pkill osrm-routed
    - watch: [ file: osrm_update ]

osrm_daemon:
  cmd.wait:
    - cwd: {{ pillar['tm_osrmdir'] }}
    - name: |
        pkill osrm-routed
        nohup build/osrm-routed -i {{ grains['fqdn'] }} -p {{pillar['tm_osrmport']}} -t 8 extract.osrm > /dev/null 2>&1 & 
    - wait: [ cmd: osrm_update ]
    - unless: test `pgrep osrm-routed` # if it's still running, it means we didn't just rebuild our index.

osrm_logdone:
  cmd.wait:
    - name: echo "OSRM index rebuilt and daemon started." >> /var/log/salt/buildlog.html
    - watch: [ cmd: osrm_daemon ]