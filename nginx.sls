nginx:
  pkg: 
    - installed
    - require:
        - pkg: tilemill
  service.running:
    - enable: True
    - watch:
      - file: /etc/nginx/sites-enabled/default

/etc/nginx/htpasswd:
  cmd.run:
    - name: |
          printf "{{grains['tm_username']}}:$(openssl passwd -crypt ""{{grains['tm_password']}}"")\n" >> /etc/nginx/htpasswd
          echo Boop!
    - unless: test -f /etc/nginx/htpasswd
  file.managed:
    - group: www-data
    - user: root
    - mode: 640

/etc/nginx/sites-enabled/default:
  file.managed:
    - source: salt://nginx-sites-enabled
    - template: jinja
    - group: root
    - user: root
    - mode: 644