tilestream_deps:
  pkg.installed:
    - names: [ curl, build-essential, libssl-dev, libsqlite3-0, libsqlite3-dev, git-core, python-pip ]

nodeenv:
  pip.installed: 
    - require: [ pkg: tilestream_deps ] 

tilestream_git:
  file.directory:
    - name: {{pillar.tm_dir}}/tilestream
    - user: mapbox
    - group: mapbox

  git.latest:
    - name: https://github.com/mapbox/tilestream
    - target: {{pillar.tm_dir}}/tilestream
    - user: mapbox


tilestream_nodeenv:
  cmd.run:
    - name: nodeenv env --node=0.8.15 # Whoa, this step is slow.
    - cwd: {{pillar.tm_dir}}/tilestream
    - user: mapbox
    - require: [ git: tilestream_git, pip: nodeenv ]
    - unless: test -f {{pillar.tm_dir}}/tilestream/env/bin/activate


tilestream_install:
  cmd.wait:
    - cwd: {{pillar.tm_dir}}/tilestream
    - user: mapbox
    - name: |
        . env/bin/activate
        npm install
  watch: [ git: tilestream_git ]

/etc/init/tilestream.conf:
  file.managed:
    - source: salt://tilestream/init-tilestream.conf
    - template: jinja

/var/log/salt/tilestream.log:
  file.managed:
    - user: mapbox
    - group: mapbox

tilestream:
  service.running:
    - enable: True
    - watch: [ file: /etc/init/tilestream.conf ]
