{% set buildtitle = "Your server is building" %}
{% set buildsubtitle = "Sit back and relax. Your server will be ready soon." %}
{% set titlecolor = "hsl(210,40%,80%)" %}
/var/log/salt/buildlog.html:
  file.managed:
    - source: salt://initlog.html
    - template: jinja
    #- unless: test -f /var/log/salt/buildlog.html
  
initlogappend:
  file.append:
    - name: /var/log/salt/buildlog.html
    - text: Commencing build...
