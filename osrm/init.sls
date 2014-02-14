osrm_deps:
  pkg.installed:
    - names: [ build-essential, git, cmake, pkg-config, libprotoc-dev, libprotobuf7,
               protobuf-compiler, libprotobuf-dev, libosmpbf-dev, libpng12-dev,
               libbz2-dev, libstxxl-dev, libstxxl-doc, libstxxl1, libxml2-dev,
               libzip-dev, libboost-all-dev, lua5.1, liblua5.1-0-dev, libluabind-dev, libluajit-5.1-dev]


osrm_repo:
  git.latest:
    - name: https://github.com/DennisOSRM/Project-OSRM.git
    - rev: master
    - target: {{pillar['tm_osrmdir']}}

###TODO expand for multiple instances
###TODO allow fetching custom profiles
osrm_build:
  cmd.wait:
    - cwd: {{pillar['tm_osrmdir']}}
    - name: |
        mkdir -p build
        cd build
        cmake ..
        make 
        cd ..
        rm profile.lua
        ln -s profiles/{{ pillar['tm_osrmprofile'] }}.lua profile.lua
    - watch: [ git: osrm_repo ]
