# Probably should actually check whether the server did build ok...
finishlog:
  cmd.script:
    - source: salt://log.sh
    - args: "'All done! Enjoy your new server.'"
  file.managed:
    - name: /var/log/salt/index.html
    - source: {{ pillar.tm_dir}}/initindex.html
    - template: jinja
    - context:
        buildtitle: "Your server is ready!"
        buildsubtitle: "Get in there and make something."
        buildtitlecolor: "hsl(130,70%,70%)"

