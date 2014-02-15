initlog:
  cmd.run:
    - name: |
       echo "<!DOCTYPE html><html><head><meta http-equiv="refresh" content="5" /></head><body><pre>" > /var/log/salt/buildlog.html
    - unless: test -f /var/log/salt/buildlog.html
  file.append:
    - name: /var/log/salt/buildlog.html
    - text: Commencing build...
