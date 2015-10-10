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
    - mode: 774
    - user: ubuntu
    - group: ubuntu
    - context:
        port: {{instance.port}}

{{pillar.tm_osrmdir}}/{{instance.profile}}/update-osrm.sh:
  file.managed:
    - source: salt://osrm/update-osrm.sh
    - template: jinja
    - mode: 774
    - user: ubuntu
    - group: ubuntu
    - context:
        port: {{instance.port}}

{% endfor %}

# Allow osrm to lock lots of memory.
osrm_memlock:
  file.append:
    - name: /etc/security/limits.conf
    - text:
        - ubuntu           hard    memlock         unlimited
        - ubuntu           soft    memlock         68719476736

# Apparently we need to do this too. https://github.com/Project-OSRM/osrm-backend/wiki/Configuring-and-using-Shared-Memory
# Not sure what to do about "(and /etc/pam.d/common-session)" because that file doesn't have this text, on 14.04.
osrm_pam:
  file.uncomment:
    - name: /etc/pam.d/su
    - regex: " session    required   pam_limits.so"

osrm_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    # Requires Jinja 2.7 - a... {# and built with profiles: {{ pillar.tm_osrminstances | map(attribute='profile') | join(', ') }}'" #}
    - args: "'OSRM installed and built.'"
    - watch: [ { cmd: osrm_build } ]

# Todo: Add this to /etc/sysctl.conf  (careful, the postgres install also plays with these settings...)
#kernel.shmall = 1152921504606846720
#kernel.shmmax = 18446744073709551615

# Todo: add this script to startup:
# ./osrm-datastore extract.osrm

# Then change the startup line to:
# ./osrm-routed -p 5010 -t 8 --sharedmemory=yes
