
python-software-properties:
  pkg.installed


{% if pillar.tm_dev is not defined or not pillar.tm_dev %}
ppa:developmentseed/mapbox:
  pkgrepo.managed


tilemill:
  pkg.installed

{% else %}
# Installing Tilemill from source
{# consider purging old ppas...
# First, clear out any old mapnik or node.js installs that might conflict
apt-get purge libmapnik libmapnik-dev mapnik-utils nodejs
 
# Also clear out any old ppa's that might conflict
rm /etc/apt/sources.list.d/*mapnik*
rm /etc/apt/sources.list.d/*developmentseed*
rm /etc/apt/sources.list.d/*chris-lea*
#}

mapbox:
  group:
    - present
  user.present:
    - home: /usr/share/mapbox
    - createhome: True
    - fullname: "Mapbox developer account"


dev-ppas:
  pkgrepo.managed:
    - names: [  ppa:chris-lea/node.js, ppa:mapnik/v2.2.0 ]

dev-deps:
  pkg.installed: 
    - names: [ nodejs, git, build-essential, libgtk2.0-dev, libwebkitgtk-dev, 
               protobuf-compiler, libprotobuf-lite7, libprotobuf-dev, libgdal1-dev]

mapnik-pkg:
  pkg.installed:
    - names: [ libmapnik-dev, mapnik-utils ]

tilemill-dev:
  cmd.run:
    - cwd: /usr/share/mapbox
    - user: mapbox
    - group: mapbox
    - name: |
      wget -nv https://github.com/mapbox/tilemill/archive/master.zip -O tilemill.zip
      unzip tilemill.zip
      mv tilemill-master tilemill
      cd tilemill
      npm install
      nohup ./index.js 
  file.managed:
    - name: /etc/init/tilemill.conf
    - source: salt://tilemill/init-tilemill.conf    

{% endif %}

/etc/tilemill/tilemill.config:
  file.managed:
    - source: salt://tilemill/tilemill.config
    - user: mapbox
    - group: mapbox
    - template: jinja
    - mode: 644
    - require:
        - pkg: tilemill

tilemill_service:
  service.running:
    - name: tilemill
    - enable: True
    - watch: [ file: /etc/tilemill/tilemill.config ]


tilemill_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Tilemill installed and configured  {% if pillar.tm_dev is defined and pillar.tm_dev %}(in dev mode){% endif %}.'"
    - watch: [ file: /etc/tilemill/tilemill.config ]        

{#
tilemill_dev:

#eemaybe not sudo apt-get install -y build-essential python-dev libbz2-dev libicu-dev

wget https://gist.github.com/springmeyer/2164897/raw/install-tilemill-latest.sh -O - | bash

#}