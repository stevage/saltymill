prereqs:
  pkg.installed:
    - names: [ unzip, wget ]

getfonts:
  cmd.run:
    - cwd: /usr/share/fonts/truetype
    - name: "wget --content-disposition '{{pillar.tm_fonts|join(' ')}}'"
    - unless what?? unless: test -f '/usr/share/fonts/truetype/*.zip'

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
