nginx:
  pkg: 
    - installed
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

"salt://log.sh 'and some arguments'":
  cmd.wait_script:
    #- source: salt://log.sh
    #- args: '"Nginx server installed and configured"'
    - watch: [ file: /etc/nginx/sites-enabled/default ]
