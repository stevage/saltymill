{% if pillar['tm_projects'] %}
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
{% endif %}