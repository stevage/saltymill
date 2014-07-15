include: [ osm.postgres ]
install_postgis_pkgs:
  pkg.installed:
    - names: [ policykit-1, postgresql-{{ pillar.tm_postgresversion }}, libpq-dev, postgis ]

config_postgis:
  cmd.script:
    - source: salt://osm/config-postgis.sh
    - cwd: {{pillar.tm_dir}}
    - watch: [ pkg: install_postgis_pkgs ]
    - require: [ service: postgresql ]
    # If we can already connect to a gis database, we don't need to do this.
    - unless: sudo -u postgres psql -d gis -c '' 2>/dev/null

postgis_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: '"Postgis installed and configured."'
    - watch: [ cmd: config_postgis ]
