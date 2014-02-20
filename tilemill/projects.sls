# Download any arbitrary zipped project files and unzip them.
# TODO: figure out how to make them 'favourites'
{% if pillar.tm_projects is defined %}
{% for project in pillar.tm_projects %}
get_{{ project.name }}:
  cmd.run:
    - cwd: /usr/share/mapbox/project
    - user: mapbox
    - name: |
        wget -nv {{ project.source }} -O {{ project.name }}.zip
        mkdir {{ project.name }}        
        unzip -o {{ project.name }}.zip # Would be nice to unzip into this name, but too hard.
        
    - unless: test -d /usr/share/mapbox/project/{{ project.name }}.zip
{% endfor %}

projects_logdone:
  cmd.script:
    - source: salt://log.sh
    - args: "'Sample projects downloaded and unzipped.'"
    # We hope... (no explicit checking whether this step even got run)
{% endif %}

