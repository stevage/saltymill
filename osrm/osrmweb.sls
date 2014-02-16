{#
# TODO options:
- web location?
  - disk location?
- layers
- bit.ly service
- use the routing port...

# TODO
#}
/usr/share/nginx/www/osrm:
  file.directory:
    - user: ubuntu
    - group: ubuntu
    - mode: 755

osrmweb_repo:
  git.latest:
    - name: https://github.com/DennisSchiefer/Project-OSRM-Web.git
    - target: /usr/share/nginx/www/osrm
    - user: ubuntu

/usr/share/nginx/www/osrm/WebContent/index.html:
  file.symlink:
    - target: /usr/share/nginx/www/osrm/WebContent/main.html

# Point our new OSRM Web install at our OSRM instance, instead of the default.
# The file.blockreplace cannot come soon enough.
configure_osrmweb:
  cmd.run:
    - cwd: /usr/share/nginx/www/osrm/WebContent
    - name: |
        python <<EOF
        import os, sys, re
        os.rename('OSRM.config.js', 'OSRM.config.js.orig')
        # In the process we convert line endings for some reason. :/
        with open('OSRM.config.js.orig', 'r') as fin, open('OSRM.config.js', 'w') as fout:
            data = fin.read()
            
            data = re.sub(r'(ROUTING_ENGINES: \[).*?(\s+\],)', r'\1\n' +
              '{\n' + 
              '  url: "http://{{ grains.fqdn }}:{{ pillar.tm_osrmport}}/viaroute",\n' +
              '  timestamp:  "http://{{ grains.fqdn }}:{{ pillar.tm_osrmport}}/timestamp",\n' +
              '  metric: 1,\n' +
              '  label: "Default",\n' # Need to make this an option
              '}\n' +
              r'\2\n', data, flags=re.DOTALL)
            fout.write(data)
        EOF
        echo
        if [ "`diff OSRM.config.js OSRM.config.js.orig`" ]; then echo "changed=yes"; else echo "changed=no"; fi
    - stateful: True
    #- watch [ git: osrmweb_repo ]


osrmweb_logdone:
  cmd.wait:
    - name: |
        echo "OSRM web interface installed and configured.<br/>" >> /var/log/salt/buildlog.html
    - watch: [ { file: /usr/share/nginx/www/osrm/WebContent/index.html } ]