
python-software-properties:
  pkg.installed


{% if pillar.tm_dev is not defined or not pillar.tm_dev %}
ppa:developmentseed/mapbox:
  pkgrepo.managed


tilemill:
  pkg.installed

{% else %}
# Installing Tilemill from source. We try to make the end result look as much like the apt-get install as possible.
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
    - groups: [ mapbox ]
    - createhome: True
    - fullname: "Mapbox developer account"


dev-ppas:
  pkgrepo.managed:
    - names: [ 'ppa:chris-lea/node.js' , 'ppa:mapnik/v2.2.0' ]

dev-deps:
  pkg.installed: 
    - names: [ nodejs, git, build-essential, libgtk2.0-dev, libwebkitgtk-dev, 
               protobuf-compiler, libprotobuf-lite7, libprotobuf-dev, libgdal1-dev]


mapnik-pkg:
  pkg.installed:
    - names: [ libmapnik-dev, mapnik-utils ]

tilemill-dirs:
  file.directory:
    - user: mapbox
    - group: mapbox
    - mode: 755
    - names: [ /usr/share/tilemill, /etc/tilemill, /var/log/tilemill ]  

tilemill-dev:
  cmd.run:
    - cwd: /usr/share
    - user: mapbox
    - group: mapbox
    - name: |
        git clone --single-branch --branch=master --depth=1 https://github.com/mapbox/tilemill tilemill
        cd tilemill
        npm install
        mkdir /usr/share/mapbox/project
        # nohup ./index.js &
    - unless: test -f /usr/share/tilemill/index.js
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
{% if pillar.tm_dev is not defined or not pillar.tm_dev %}
    - require:
        - pkg: tilemill
{% endif %}
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