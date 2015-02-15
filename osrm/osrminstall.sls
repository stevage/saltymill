osrm_deps:
  pkg.installed:
    - names: [ build-essential, git, cmake, pkg-config, libprotoc-dev, libprotobuf8,
               protobuf-compiler, libprotobuf-dev, libosmpbf-dev, libpng12-dev,
               libbz2-dev, libstxxl-dev, libstxxl-doc, libstxxl1, libxml2-dev,
               libzip-dev, libboost-all-dev, lua5.1, liblua5.1-0-dev, libluabind-dev, libluajit-5.1-dev, libtbb-dev ]
    #- order: 1
    ### Oh, I think the problem is we can't build on Precise.

osrm_repo:
  git.latest:
    - name: https://github.com/DennisOSRM/Project-OSRM.git
    - user: ubuntu
    - rev: master
    - target: {{pillar['tm_osrmdir']}}

osrm_build:
  cmd.run:
    - cwd: {{pillar['tm_osrmdir']}}
    - user: ubuntu
    - name: |
        mkdir -p build
        cd build
        cmake ..
        make
    - unless: test -f {{ pillar.tm_osrmdir }}/build/osrm-routed  # Ideally we'd allow rebuilding on git changes?
    - watch: [ git: osrm_repo ] # this trigger not working?
    - require: [ pkg: osrm_deps ]

# We build OSRM once, then copy the executables to each of the instances.

{% for instance in pillar['tm_osrminstances'] %}
# Profiles have to be unique atm. Probably ok?
osrm_instance_{{ instance.profile }}:
  cmd.wait:
    - name: |
        mkdir {{ pillar.tm_osrmdir }}/{{instance.profile}}
        cd {{ pillar.tm_osrmdir }}/{{instance.profile}}
        cp {{ pillar.tm_osrmdir }}/build/osrm-* .
        cp -R ../profiles .
        {% if instance.profilesource is defined %}
        wget -nv {{ instance.profilesource }} -O profile.lua
        {% else %}
        cp profiles/{{ instance.profile }}.lua profile.lua
        {% endif %}
    - user: ubuntu
    - watch: [ cmd: osrm_build ]
    - unless: test -d {{ pillar.tm_osrmdir }}/{{ instance.profile }}

{{pillar.tm_osrmdir}}/{{instance.profile}}/start-osrm.sh:
  file.managed:
    - source: salt://osrm/start-osrm.sh
    - template: jinja
    - permissions: 774
    - user: ubuntu
    - context:
        port: {{instance.port}}

{{pillar.tm_osrmdir}}/{{instance.profile}}/update-osrm.sh:
  file.managed:
    - source: salt://osrm/update-osrm.sh
    - template: jinja
    - permissions: 774
    - user: ubuntu
    - context:
        port: {{instance.port}}

{% endfor %}



osrm_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    # Requires Jinja 2.7 - a... {# and built with profiles: {{ pillar.tm_osrminstances | map(attribute='profile') | join(', ') }}'" #}
    - args: "'OSRM installed and built.'"
    - watch: [ { cmd: osrm_build } ]

# Todo: Add this to /etc/sysctl.conf  (careful, the postgres install also plays with these settings...)

# Todo: Add this to /etc/security/limits.conf (and also change all the above to install as ubuntu, not root).


#ubuntu           hard    memlock         unlimited
#ubuntu           soft    memlock         68719476736

# Todo: add this script to startup:
# ./osrm-datastore extract.osrm

# Then change the startup line to:
# ./osrm-routed -p 5010 -t 8 --sharedmemory=yes
