install_postgis:
  cmd.script:
    - source: salt://osm/install-postgis.sh
  #sysctl.present:
  #  kernal.shmmax

postgresql:
  service.running:
    - enable: True
    - require: [ cmd: install_postgis ]
    - reload: True

update_data:
  cmd.script:
    - source: salt://osm/update-data.sh
    - user: ubuntu
    - group: ubuntu
    - require: [ cmd: install_postgis ]

