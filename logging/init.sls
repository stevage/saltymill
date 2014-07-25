logio_deps:
  names: [ nodejs-legacy, npm ]
  pkg.installed

install_logio:
  cmd.run:
    - cwd: /home/ubuntu 
    - name: |
        npm install -y log.io
    - require:
      - pkg: logio_deps

/home/ubuntu/.logio/harvester.conf:
  file.managed:
    - source: salt://logging/harvester.conf
    - template: jinja

/home/ubuntu/.logio/web_server.conf:
  file.managed:
    - source: salt://logging/web_server.conf
    - template: jinja

run_logio:
  cmd.run:
    - name: |
        nohup log.io-server &
        nohup log.io-harvester &
