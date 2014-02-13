ppa:kakrueger/openstreetmap:
  pkgrepo.managed

deps:
  pkg.installed:
    - names: [ software-properties-common, git, unzip ] 

oms2pgsql:
  pkg.installed

{{grains['tm_dir']}}/import.sh:
  file.managed:
    - source: salt://osm/import.sh
    - user: ubuntu
    - group: ubuntu
    - mode: 744

{{grains['tm_dir']}}/process.sh:
  file.managed:
    - source: salt://osm/process.sh
    - user: ubuntu
    - group: ubuntu
    - mode: 744



# what if I skip this line?
###TODO
#export DEBIAN_FRONTEND=noninteractive
#apt-get install -y osm2pgsql
