finishlog:
  cmd.run:
    - name: |
        echo "All done! Enjoy your new server.<br/>" >> /var/log/salt/buildlog.html
  file.managed:
    - name: /var/log/salt/index.html
    - source: salt://initindex.html
    - template: jinja
    - context:
      - buildtitle: "Your server is read!"
      - buildsubtitle: "Get in there and make something."
      - buildtitlecolor: "hsl(130,70%,70%)"

