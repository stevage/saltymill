prereqs:
  pkg.installed:
    - names: [ unzip, wget ]

{% for font in pillar.tm_fonts %}
getfont_{{font}}:
  cmd.run:
    - cwd: /usr/share/fonts/truetype
    - name: "wget '{{font}}'"
    #- unless what?? unless: test -d /usr/share/fonts/truetype/CartoGothic
{% endfor %}

unzip_fonts:
  cmd.run
    - cwd: /usr/share/fonts/truetype
    - name: "unzip -d . -o *.zip"
    - require: [ { pkg: prereqs } ]

fonts_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Fonts downloaded and unzipped.'"
    - watch: [ { cmd: fonts } ]
