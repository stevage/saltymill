/var/log/salt/buildlog.html:
  file.managed:
    - source: salt://initlog.html
    #- unless: test -f /var/log/salt/buildlog.html
  file.append:
    - name: /var/log/salt/buildlog.html
    - text: Commencing build...
