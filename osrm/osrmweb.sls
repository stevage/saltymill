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
            {% for instance in pillar.tm_osrminstances %}
              '{\n' + 
              '  url: "http://{{ grains.fqdn }}:{{ instance.port}}/viaroute",\n' +
              '  timestamp:  "http://{{ grains.fqdn }}:{{ instance.port}}/timestamp",\n' +
              '  metric: 1,\n' +
              '  label: "{{ instance.name }}",\n'
              '}, ' +
            {% endfor %}
              r'\2\n', data, flags=re.DOTALL)
            fout.write(data)
        EOF
        echo
        if [ "`diff -bW OSRM.config.js OSRM.config.js.orig`" ]; then echo "changed=yes"; else echo "changed=no"; fi
    - stateful: True
    #- watch [ git: osrmweb_repo ]


osrmweb_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'OSRM web interface installed and configured.'"
    - watch: [ { file: /usr/share/nginx/www/osrm/WebContent/index.html } ]
