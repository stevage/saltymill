osrm_deps:
  pkg.installed:
    - names: [ build-essential, git, cmake, pkg-config, libprotoc-dev, libprotobuf7,
               protobuf-compiler, libprotobuf-dev, libosmpbf-dev, libpng12-dev,
               libbz2-dev, libstxxl-dev, libstxxl-doc, libstxxl1, libxml2-dev,
               libzip-dev, libboost-all-dev, lua5.1, liblua5.1-0-dev, libluabind-dev, libluajit-5.1-dev]
    #- order: 1
    ### Oh, I think the problem is we can't build on Precise.

osrm_repo:
  git.latest:
    - name: https://github.com/DennisOSRM/Project-OSRM.git
    - rev: master
    - target: {{pillar['tm_osrmdir']}}

###TODO expand for multiple instances
###TODO allow fetching custom profiles
osrm_build:
  cmd.run:
    - cwd: {{pillar['tm_osrmdir']}}
    - name: |
        mkdir -p build
        cd build
        cmake ..
        make 
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
      wget {{ instance.profilesource }} -O profile.lua
      {% else %}
      cp profiles/{{ instance.profile }}.lua profile.lua
      {% endif %}
    - watch: [ cmd: osrm_build ]
    - unless: test -d {{ pillar.tm_osrmdir }}/{{ instance.profile }}
{% endfor %}

osrm_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'OSRM installed and built with profiles: {{ pillar.tm_osrminstances | map(attribute='profile') | join(', ') }}'"
    - watch: [ { cmd: osrm_build } ]

