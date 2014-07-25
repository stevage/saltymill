nodejs-legacy:  
  pkg.installed  
  
npm:  
  pkg.installed  

at:
  pkg.installed
  
install_logio:  
  cmd.run:  
    - name: |  
        npm install -g log.io  
    - require:  
      - pkg: nodejs-legacy  
      - pkg: npm  
  
/home/ubuntu/.log.io/harvester.conf:  
  file.managed:  
    - source: salt://logging/harvester.conf  
    - template: jinja  
  
/home/ubuntu/.log.io/web_server.conf:  
  file.managed:  
    - source: salt://logging/web_server.conf  
    - template: jinja  
  
run_logio:  
  cmd.run:  
    - name: |  
        # Clumsy workaround for salt minion issue with backgrounded tasks. 
        # https://groups.google.com/forum/#!msg/salt-users/wymM8NrslNw/hytrpuNEOPUJ
        echo "nohup log.io-server" | at now
        echo "nohup log.io-harvester" | at now
