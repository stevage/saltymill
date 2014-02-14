# TODO web location?

/usr/share/nginx/www/osrm:
  file.directory:
    - user: ubuntu
    - group: ubuntu
    - mode: 755

https://github.com/DennisSchiefer/Project-OSRM-Web.git:
  git.latest:
    - target: /usr/share/nginx/www/osrm
    - user: ubuntu

  