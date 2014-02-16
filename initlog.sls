{% set build.title = "Your server is building" %}
{% set build.subtitle = "Sit back and relax. Your server will be ready soon." %}
{% set build.titlecolor = "hsl(210,40%,80%)" %}

initindex:
  file.managed:
    - name: /var/log/salt/index.html
    - source: salt://initindex.html
    - template: jinja


/var/log/salt/buildlog.html:
  file.managed:
    - source: salt://initlog.html
    - template: jinja
