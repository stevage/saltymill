{% for instance in pillar.tm_osrminstances %}
osrm_daemon_{{instance.profile}}:
  cmd.run:
    - cwd: {{ pillar.tm_osrmdir }}/{{instance.profile}}
    - name: |
        # Strangely, listening on a non-IP doesn't seem to work. And listening on 0.0.0.0 (default) works just fine.
        # nohup ./osrm-routed -i {{ grains.fqdn }} -p {{instance.port}} -t 8 extract.osrm > /dev/null 2>&1 & 
        nohup ./osrm-routed -p {{instance.port}} -t 8 extract.osrm > /dev/null 2>&1 & 
    # - wait: [ cmd: osrm_reindex ] # Bah, for some reason, the OSRM build is returning a failure?
    - unless: test "`curl localhost:{{ instance.port }}`" 

updateosrm_logdone_{{instance.profile}}:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'OSRM daemon started for profile {{ instance.name }} on port {{ instance.port}}.'"
    - watch: [ cmd: osrm_daemon_{{instance.profile}} ]
{% endfor %}