{{grains['tm_dir']}}/tm-settings:
  file.managed:
    - source: salt://osm/tm-settings
    - template: jinja
    - user: ubuntu
    - group: ubuntu
    - mode: 744

{{grains['tm_dir']}}/getspecs.sh:
  file.managed:
    - source: salt://osm/getspecs.sh
    - template: jinja
    - user: ubuntu
    - group: ubuntu
    - mode: 744

install_postgis:
  cmd.script:
    - source: salt://osm/install-postgis.sh
    - cwd: {{grains['tm_dir']}}
  #sysctl.present:
  #  kernal.shmmax


{{grains['tm_dir']}}:
  file.directory:
    - group: ubuntu
    - user: ubuntu
    - makedirs: True


{{grains['tm_dir']}}/import.sh:
  file.managed:
    - source: salt://osm/import.sh
    - user: ubuntu
    - group: ubuntu
    - mode: 744

{{grains['tm_dir']}}/process.sh:
  file.managed:
    - source: salt://osm/process.sh
    - user: ubuntu
    - group: ubuntu
    - mode: 744

postgresql:
  service.running:
    - enable: True
    - require: [ cmd: install_postgis ]
    - reload: True
