ppa:kakrueger/openstreetmap:
  pkgrepo.managed

deps:
  pkg.installed:
    - names: [ software-properties-common, git, unzip ] 

osm2pgsql:
  pkg.installed

{{pillar['tm_dir']}}/import.sh:
  file.managed:
    - source: salt://osm/import.sh
    - user: ubuntu
    - group: ubuntu
    - mode: 774

{{pillar['tm_dir']}}/process.sh:
  file.managed:
    - source: salt://osm/process.sh
    - user: ubuntu
    - group: ubuntu
    - mode: 774

{{pillar['tm_dir']}}/customised.style:
  file.managed:
    - source: salt://osm/customised.style
    - user: ubuntu
    - group: ubuntu
    - mode: 664



# what if I skip this line?
###TODO
#export DEBIAN_FRONTEND=noninteractive
#apt-get install -y osm2pgsql
