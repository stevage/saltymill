nginx:
  pkg: 
    - installed
    #- require: # really? why?
    #    - pkg: tilemill
  service.running:
    - enable: True
    - watch:
      - file: /etc/nginx/sites-enabled/default

/etc/nginx/htpasswd:
  cmd.run:
    - name: |
          printf "{{pillar['tm_username']}}:$(openssl passwd -crypt ""{{pillar['tm_password']}}"")\n" > /etc/nginx/htpasswd
    # - unless: test -f /etc/nginx/htpasswd
    # on second thoughts, always replace the username/password

  file.managed:
    - group: www-data
    - user: root
    - mode: 640

/etc/nginx/sites-enabled/default:
  file.managed:
    - source: salt://nginx/sites-enabled-default
    - template: jinja
    - group: root
    - user: root
    - mode: 644

nginxlog: 
  {% set log = log ~ "Nginx server installed and configured.<br/>" %}
  file.managed:
    - name: /var/log/salt/buildlog.html
    - source: salt://initlog.html
    - template: jinja
    - require: [ file: /etc/nginx/sites-enabled/default ]


