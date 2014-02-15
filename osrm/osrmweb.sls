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

https://github.com/DennisSchiefer/Project-OSRM-Web.git:
  git.latest:
    - target: /usr/share/nginx/www/osrm
    - user: ubuntu

/usr/share/nginx/www/osrm/WebContent/index.html:
  file.symlink:
    - target: /usr/share/nginx/www/osrm/WebContent/main.html

  