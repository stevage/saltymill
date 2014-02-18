
kernel.shmmax:
  sysctl.present:
    - value: {{ (grains['mem_total'] // 4 + 1000) * 1000000 }}
kernel.shmall:
  sysctl.present:
    - value: {{ (grains['mem_total'] // 4 + 1000) * 1000000 }}


install_postgres_pkgs:
  pkg.installed:
    - names: [ policykit-1, postgresql-9.1, libpq-dev ]

postgresinstall_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: '"Postgres installed, now configuring."'
    - watch: [ { pkg: install_postgres_pkgs } ]

move_postgres:
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


postgres_conf:
  file.append:
    - name: /etc/postgresql/9.1/main/postgresql.conf
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

postgresql:
  service.running:
    - enable: True
    - watch: [ pkg: install_postgres_pkgs, cmd: move_postgres, file: postgres_conf ]

postgres_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: '"Postgres installed and configured."'
    - watch: [ file: /etc/postgresql/9.1/main/postgresql.conf ]
