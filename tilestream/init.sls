tilestream_git:
  file.directory:
    - name: {{pillar.tm_dir}}/tilestream
    - user: mapbox
    - group: mapbox

  git.latest:
    - name: https://github.com/mapbox/tilestream
    - target: {{pillar.tm_dir}}/tilestream
    - user: mapbox

/etc/init/tilestream.conf:
  file.managed:
    - source: salt://tilestream/init-tilestream.conf
    - template: jinja

tilestream:
  service.running:
    - enable: True
