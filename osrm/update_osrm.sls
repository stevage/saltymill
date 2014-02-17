###TODO call update_data to get the latest data in one hit.
{% for instance in pillar.tm_osrminstances %}
osrm_update_{{instance.profile}}:
  file.copy:
    - name: {{ pillar.tm_osrmdir }}/{{ instance.profile }}/extract.osm.pbf
    - source: {{ pillar.tm_dir }}/extract.osm.pbf
    # - require: [ cmd: update_data ] # Needs an include?

osrm_start:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Building OSRM index for {{instance.name}}...'"
    - onlyif: test -f {{pillar.tm_osrmdir}}/{{ instance.profile }}/osrm-routed 
    - watch: [ file: osrm_update ] 

osrm_reindex:
  cmd.wait:
    - cwd: {{pillar.tm_osrmdir}}/{{instance.profile}}
    - name: |
        build/osrm-extract extract.osm.pbf
        build/osrm-prepare extract.osrm
        pkill -f 'osrm-routed.*-p {{ instance.port }}' # Make sure we kill the right instance.
        echo "OSRM index for profile '{{ instance.name}}' rebuilt.<br/>" >> /var/log/salt/buildlog.html
        exit 0 # so Salt doesn't think it failed?
    - watch: [ cmd: osrm_start ]

osrm_daemon:
  cmd.run:
    - cwd: {{ pillar.tm_osrmdir }}
    - name: |
        nohup build/osrm-routed -i {{ grains.fqdn }} -p {{instance.port}} -t 8 extract.osrm > /dev/null 2>&1 & 
    # - wait: [ cmd: osrm_reindex ] # Bah, for some reason, the OSRM build is returning a failure?
    - unless: test "`curl localhost:{{ instance.port }}`" 

updateosrm_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'OSRM daemon started for profile {{ instance.name }} on port {{ instance.port}}.'"
    - watch: [ cmd: osrm_daemon ]
{% endfor %}