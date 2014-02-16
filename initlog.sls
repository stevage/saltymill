initindex:
  file.managed:
    - name: /var/log/salt/index.html
    - source: salt://initindex.html
    - template: jinja
    - context:
        buildtitle: "Your server is building"
        buildsubtitle: "Sit back and relax. Your server will be ready soon."
        buildtitlecolor: "hsl(210,40%,80%)"


/var/log/salt/buildlog.html:
  file.managed:
    - source: salt://initlog.html
    - template: jinja
