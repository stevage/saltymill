update_data:
  cmd.script:
    - source: salt://osm/update-data.sh
    - user: ubuntu
    - group: ubuntu
    - require: [ cmd: install_postgis ]

