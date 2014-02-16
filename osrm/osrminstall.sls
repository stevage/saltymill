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
        cd ..
        rm profile.lua
        {% if pillar['tm_osrmprofilesource'] is defined %}
        wget {{ pillar['tm_osrmprofilesource'] }} -O profile.lua
        {% else %}
        ln -s profiles/{{ pillar['tm_osrmprofile'] }}.lua profile.lua
        {% endif %}
    - watch: [ git: osrm_repo ] # this trigger not working?
    - require: [ pkg: osrm_deps ]

osrm_logdone:
  cmd.wait:
    - name: |
        echo "OSRM installed and built.<br/>" >> /var/log/salt/buildlog.html
    - watch: [ { cmd: osrm_build } ]



{# Multiple instances something like:

tm_osrminstances:
  - hiking:              # used in OSRMweb?
    - profile: hiking
    - source: http://... # optional?
    - port: 5011

#}