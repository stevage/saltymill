prereqs:
  pkg.installed:
    - names: [ unzip, wget ]

getfonts:
  cmd.run:
    - name: |
        mkdir -p /usr/share/fonts/truetype
        cd /usr/share/fonts/truetype
        {% for font in pillar.tm_fonts %}wget -nv --content-disposition '{{font}}' ;  {% endfor %}
    - unless: test "`find /usr/share/fonts/truetype -iname '*.zip'`"

unzip_fonts:
  cmd.wait:
    - cwd: /usr/share/fonts/truetype
    - name: "unzip -d . -o '*.zip'"
    - require: [ pkg: prereqs ]
    - watch: [ cmd: getfonts ]

fonts_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Fonts downloaded and unzipped.'"
    - watch: [ { cmd: unzip_fonts } ]
