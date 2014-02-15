# Install and configure OSM2PGSQL, the tool for importing OSM extracts into Postgres.
ppa:kakrueger/openstreetmap:
  pkgrepo.managed

osm2pgsqldeps:
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
    #- use:
    - group: ubuntu
    - mode: 774

{{pillar['tm_dir']}}/customised.style:
  file.managed:
    - source: salt://osm/customised.style
    - user: ubuntu
    - group: ubuntu
    - mode: 664

osm2pgsql_logdone:
  cmd.wait:
    - name: echo "OSM2PGSQL installed." >> /var/log/salt/buildlog.html
    - watch: [ file: {{pillar['tm_dir']}}/customised.style ]        

# what if I skip this line?
###TODO
#export DEBIAN_FRONTEND=noninteractive
#apt-get install -y osm2pgsql
