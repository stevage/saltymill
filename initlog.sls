/var/log/salt/buildlog.html:
  file.managed:
    - source: salt://initlog.html
    - template: jinja
    #- unless: test -f /var/log/salt/buildlog.html
  
initlogappend:
  file.append:
    - name: /var/log/salt/buildlog.html
    - text: Commencing build...
