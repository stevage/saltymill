OSRMDIR=osrm
OSRMPROFILE=bicycle


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
    - target: {{pillar('tm_osrmdir')}}

###TODO expand for multiple instances
###TODO allow fetching custom profiles
osrm_build:
  cmd.wait:
    - cwd: {{pillar('tm_osrmdir')}}
    - name: |
        mkdir -p build
        cd build
        cmake ..
        make 
        cd ..
        rm profile.lua
        ln -s profiles/{{tm_osrmprofile}}.lua profile.lua
    - watch: [ git: osrm_repo ]

#cp ../../osrm/incoming.* .
#build/osrm-extract incoming.osm.pbf
#build/osrm-prepare incoming.osrm 
#build/osrm-routed -i cycletour.org -p 5010 -t 8 --hsgrdata incoming.osrm.hsgr --nodesdata incoming.osrm.nodes 