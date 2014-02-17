{% if pillar['tm_projects'] is defined %}
{% for project in pillar['tm_projects'] %}
{{ project }}:
  cmd.run:
    - name: |
        wget {{ project }}
        unzip *.zip   # may sort of conflict with waterpolygons
        rm *.zip
    - cwd: /usr/share/mapbox/project
    # TODO: figure out how to work out the file name in advance, and hence avoid running this task if needless
{% endfor %}

projects_logdone:
  cmd.script:
    - source: salt://log.sh
    - args: "'Sample projects downloaded and unzipped.'"
    # We hope... (no explicit checking whether this step even got run)
{% endif %}

