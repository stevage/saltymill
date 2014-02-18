prereqs:
  pkg.installed:
    - names: [ unzip, wget ]

getfonts:
  cmd.run:
    - cwd: /usr/share/fonts/truetype
    - name: "wget '{{pillar.tm_fonts|join(' ')}}'"
    #- unless what?? unless: test -d /usr/share/fonts/truetype/CartoGothic

unzip_fonts:
  cmd.run:
    - cwd: /usr/share/fonts/truetype
    - name: "unzip -d . -o *.zip"
    - require: [ { pkg: prereqs } ]

fonts_logdone:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Fonts downloaded and unzipped.'"
    - watch: [ { cmd: unzip_fonts } ]
