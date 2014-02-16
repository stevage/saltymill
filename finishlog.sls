finishlog:
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'All done! Enjoy your new server.'"
  file.managed:
    - name: /var/log/salt/index.html
    - source: salt://initindex.html
    - template: jinja
    - context:
        buildtitle: "Your server is ready!"
        buildsubtitle: "Get in there and make something."
        buildtitlecolor: "hsl(130,70%,70%)"

