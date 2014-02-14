preamble:
  cmd.run:
      - name: |
          echo "127.0.0.1 `hostname`" >> /etc/hosts
          echo "Australia/Melbourne" | sudo tee /etc/timezone
          sudo dpkg-reconfigure --frontend noninteractive tzdata
          sudo apt-get update
      - unless: grep -q `hostname` /etc/hosts
  group.present:
    - name: ubuntu
  user.present:
    - name: ubuntu
    - fullname: Ubuntu
    - shell: /bin/bash
    - home: /home/ubuntu
    - groups: [ ubuntu ]


ppa:developmentseed/mapbox:
  pkgrepo.managed

tilemill:
  pkg:
    - installed
  service.running:
    - enable: True
    - watch: [ file: /etc/tilemill/tilemill.config ]

/etc/tilemill/tilemill.config:
  file.managed:
    - source: salt://tilemill/tilemill.config
    - user: mapbox
    - group: mapbox
    - template: jinja
    - mode: 644
    - require:
        - pkg: tilemill