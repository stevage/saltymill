###TODO call update_data to get the latest data in one hit.

osrm_update:
  file.copy:
    - name: {{ pillar['tm_osrmdir'] }}/extract.osm.pbf
    - source: {{ pillar['tm_dir'] }}/extract.osm.pbf
    # - require: [ cmd: update_data ]

osrm_start:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Building OSRM index...'"
    - onlyif: test -f {{pillar['tm_osrmdir']}}/build/osrm-routed 
    - watch: [ file: osrm_update ] 

osrm_reindex:
  cmd.wait:
    - cwd: {{pillar['tm_osrmdir']}}
    - name: |
        build/osrm-extract extract.osm.pbf
        build/osrm-prepare extract.osrm
        pkill osrm-routed
        echo "OSRM index rebuilt.<br/>" >> /var/log/salt/buildlog.html
        exit 0 # so Salt doesn't think it failed?
    - watch: [ cmd: osrm_start ]

osrm_daemon:
  cmd.run:
    - cwd: {{ pillar['tm_osrmdir'] }}
    - name: |
        #pkill osrm-routed
        nohup build/osrm-routed -i {{ grains['fqdn'] }} -p {{pillar['tm_osrmport']}} -t 8 extract.osrm > /dev/null 2>&1 & 
    # - wait: [ cmd: osrm_reindex ] # Bah, for some reason, the OSRM build is returning a failure?
    - unless: test "`curl localhost:{{ pillar.tm_osrmport }}`" 

updateosrm_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'OSRM daemon started.'"
    - watch: [ cmd: osrm_daemon ]
