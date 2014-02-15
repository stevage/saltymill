{{pillar['tm_dir']}}:
  file.directory:
    - group: ubuntu
    - user: ubuntu
    - mode: 755
    - makedirs: True

{{pillar['tm_dir']}}/tm-settings:
  file.managed:
    - source: salt://osm/tm-settings
    - template: jinja
    - user: ubuntu
    - group: ubuntu
    - mode: 744

{{pillar['tm_dir']}}/getspecs.sh:
  file.managed:
    - source: salt://osm/getspecs.sh
    - template: jinja
    - user: ubuntu
    - group: ubuntu
    - mode: 744

kernel.shmmax:
  sysctl.present:
    - value: {{ (grains['mem_total'] // 4 + 1000) * 1000000 }}
kernel.shmall:
  sysctl.present:
    - value: {{ (grains['mem_total'] // 4 + 1000) * 1000000 }}


install_postgis_pkgs:
  pkg.installed:
    - names: [ policykit-1, postgresql-9.1, libpq-dev, postgis ]

move_postgis:
  cmd.run: 
    - name: |
        POSTGRESDIR={{pillar['tm_postgresdir']}}
        echo Moving postgresql from /var/lib/postgresql to $POSTGRESDIR/postgresql

        mkdir -p $POSTGRESDIR
        service postgresql stop
        cd /var/lib/
        mv postgresql $POSTGRESDIR
        ln -s $POSTGRESDIR/postgresql postgresql
        chmod a+r $POSTGRESDIR
        service postgresql start
    - unless: test -d "{{pillar['tm_postgresdir']}}/postgresql"

postgresql:
  service.running:
    - enable: True
    - watch: 
      - pkg: install_postgis_pkgs
      - cmd: move_postgis

config_postgis:
  cmd.script:
    - source: salt://osm/config-postgis.sh
    - cwd: {{pillar['tm_dir']}}
    - watch: [ pkg: install_postgis_pkgs ]
    - require: [ service: postgresql ]
    - stateful: True

/etc/postgresql/9.1/main/postgresql.conf:
  file.append:
    - template: jinja
    - text: |
        # Settings tuned for TileMill
        # Problem that for small servers, not enough memory left for OSRM to do its thing.
        #shared_buffers = {{grains['mem_total'] // 4}}MB
        shared_buffers = {{grains['mem_total'] // 4 - 500}}MB
        autovacuum = on
        effective_cache_size = {{grains['mem_total'] // 4}}MB
        work_mem = 128MB
        maintenance_work_mem = 64MB
        wal_buffers = 1MB

postgis_logdone:
  cmd.wait:
    - name: echo "Postgis installed and configured." >> /var/log/salt/buildlog.html
    - watch: [ file: /etc/postgresql/9.1/main/postgresql.conf ]