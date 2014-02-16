{% from 'initlog.sls' import buildtitle %}
{% from 'initlog.sls' import buildsubtitle %}
{% from 'initlog.sls' import buildtitlecolor %}

{% set buildtitle = "Your server is ready!" %}
{% set buildsubtitle = "Get in there and make something." %}
{% set titlecolor = "hsl(130,70%,70%)" %}
finishlog:
  cmd.run:
    - name: |
        echo "All done! Enjoy your new server.<br/>" >> /var/log/salt/buildlog.html
  file.managed:
    - name: /var/log/salt/index.html
    - source: salt://initindex.html
    - template: jinja

