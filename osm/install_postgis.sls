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

