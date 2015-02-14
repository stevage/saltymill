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

# Newer versions of nginx make this directory .../html so we have to make sure.
/usr/share/nginx/www:
  file.directory:
    - user: root
    - group: www-data
    - mode: 644

{% if pillar['tm_nginxurlssource'] is defined %}
nginxurls:
  cmd.run:
    - name: |
        mkdir -p /etc/nginx/includes
        chmod 755 /etc/nginx/includes
        chown ubuntu:ubuntu /etc/nginx/includes
        wget -o /etc/nginx/includes/urls {{ pillar['tm_nginxurlssource'] }}  
    # always run, so we can update urls easily.
{% endif %}      

nginxlog:
  cmd.wait_script:
    - source: salt://log.sh
    - args: '"Nginx server installed and configured."'
    - watch: [ file: /etc/nginx/sites-enabled/default ]
