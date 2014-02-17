# We copy the log template itself over so we can template with it at the end of the run. I know!
copytemplate:
  file.managed:
    - name: {{ pillar.tm_dir}}/initindex.html
    - source: salt://initindex.html    

initindex:
  file.managed:
    - name: /var/log/salt/index.html
    - source: {{ pillar.tm_dir}}/initindex.html
    - template: jinja
    - context:
        buildtitle: "Your server is building"
        buildsubtitle: "Sit back and relax. Your server will be ready soon."
        buildtitlecolor: "hsl(210,40%,80%)"

{{ pillar.tm_dir }}/buildlog.html:
  file.managed:
    - source: salt://initlog.html
    - template: jinja
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Building your new server...'"