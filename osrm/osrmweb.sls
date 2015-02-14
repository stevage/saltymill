{#
# TODO options:
- web location?
  - disk location?
- layers
- bit.ly service
- use the routing port...

# TODO
#}
/usr/share/nginx/www:
  file.directory:
    - user: ubuntu
    - group: ubuntu
    - mode: 755

/usr/share/nginx/www/osrm:
  file.directory:
    - user: ubuntu
    - group: ubuntu
    - mode: 755

# OSRM-Web uses Windows line endings. Bleh.
setcrlf:
  git.config:
    - name: core.autocrlf
    - value: input
    - user: ubuntu
    - is_global: true

osrmweb_repo:
  git.latest:
    - name: {{ pillar.tm_osrmwebgit|default('https://github.com/DennisSchiefer/Project-OSRM-Web.git') }}
    - rev: {{ pillar.tm_osrmwebgitbranch|default('master') }}
    - target: /usr/share/nginx/www/osrm
    - user: ubuntu

/usr/share/nginx/www/osrm/WebContent/index.html:
  file.symlink:
    - target: /usr/share/nginx/www/osrm/WebContent/main.html

# Point our new OSRM Web install at our OSRM instance, instead of the default.
# The file.blockreplace cannot come soon enough.
configure_osrmweb:
  cmd.script: 
    - cwd: /usr/share/nginx/www/osrm/WebContent
    - source: salt://osrm/osrm_textsub.py
    - template: jinja
    #- name: |
    #    echo
    #    if [ "`diff -bW OSRM.config.js OSRM.config.js.orig`" ]; then echo "changed=yes"; else echo "changed=no"; fi
    #- stateful: True
    #- watch [ git: osrmweb_repo ]


osrmweb_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'OSRM web interface installed and configured.'"
    - watch: [ { file: /usr/share/nginx/www/osrm/WebContent/index.html } ]
