tilestream_deps:
  pkg.installed:
    - names [ curl build-essential libssl-dev libsqlite3-0 libsqlite3-dev git-core python-pip ]
  cmd.wait:
    - name: pip install nodeenv
    - watch: [ pkg: tilestream_deps ] 

tilestream_git:
  file.directory:
    - name: {{pillar.tm_dir}}/tilestream
    - user: mapbox
    - group: mapbox

  git.latest:
    - name: https://github.com/mapbox/tilestream
    - target: {{pillar.tm_dir}}/tilestream
    - user: mapbox

tilestream_install:
  cmd.wait:
    - cwd: {{pillar.tm_dir}}/tilestream
    - user: mapbox
    - name: |
        nodeenv env --node=0.8.15 # Whoa, this step is slow.
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
