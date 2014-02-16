{% set buildtitle = "Your server is building" %}
{% set buildsubtitle = "Sit back and relax. Your server will be ready soon." %}
{% set buildtitlecolor = "hsl(210,40%,80%)" %}

initindex:
  file.managed:
    - name: /var/log/salt/index.html
    - source: salt://initindex.html
    - template: jinja


/var/log/salt/buildlog.html:
  file.managed:
    - source: salt://initlog.html
    - template: jinja
