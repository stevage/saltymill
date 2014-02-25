# Download any arbitrary zipped project files and unzip them.
# TODO: figure out how to make them 'favourites'
# Harder TODOs:
# - update all database references to be local
# - strip out/do something with all file references
{% if pillar.tm_projects is defined %}
{% for project in pillar.tm_projects %}
get_{{ project.name }}:
  cmd.run:
    - cwd: /usr/share/mapbox/project
    - user: mapbox
    - name: |
        dest={{project.name}}
        wget -nv {{ project.source }} -O $dest.zip
        mkdir $dest
        unzip -o $dest.zip -d $dest

        # If the unzipped archive contains exactly one directory, move it up a layer:
        if [ `ls $dest | wc -l` == 1 ]; then
          subdir=`ls $dest`
          mv $dest/$subdir/* $dest/
          rmdir $dest/$subdir
        fi

    - unless: test -d /usr/share/mapbox/project/{{ project.name }}.zip
{% endfor %}

projects_logdone:
  cmd.script:
    - source: salt://log.sh
    - args: "'Sample projects downloaded and unzipped.'"
    # We hope... (no explicit checking whether this step even got run)
{% endif %}


if [ `ls $dest | wc -l` == 1 ]; then
  subdir=`ls foo`
  mv foo/$subdir/* foo/
  rmdir foo/$subdir
fi