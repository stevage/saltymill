preamble:
  cmd.run:
      - name: |
          echo "127.0.0.1 `hostname`" >> /etc/hosts
          echo "Australia/Melbourne" | sudo tee /etc/timezone
          sudo dpkg-reconfigure --frontend noninteractive tzdata
          sudo apt-get update
      - unless: grep -q `hostname` /etc/hosts
  group.present:
    - name: ubuntu
  user.present:
    - name: ubuntu
    - fullname: Ubuntu
    - shell: /bin/bash
    - home: /home/ubuntu
    - groups: [ ubuntu ]
  file.directory:
    - name: {{ pillar.tm_dir}}
    - user: ubuntu
    - group: ubuntu
    - makedirs: True


{## Actually this didn't work... #}
{## We copy the log template itself over so we can template with it at the end of the run. I know!
copytemplate:
  file.managed:
    - name: {{ pillar.tm_dir}}/initindex.html
    - source: salt://initindex.html    
#}
initindex:
  file.managed:
    - name: /var/log/salt/index.html
    - source: salt://initindex.html
    - template: jinja
    - context:
        buildtitle: "Your server is building"
        buildsubtitle: "Sit back and relax. Your server will be ready soon."
        buildtitlecolor: "hsl(210,40%,80%)"
    - replace: False # We don't want to kill the file if it's already there.

{{ pillar.tm_dir }}/buildlog.html:
  file.managed:
    - source: salt://initlog.html
    - template: jinja
    - replace: False
  cmd.wait_script:
    - source: salt://log.sh
    - args: "'Building your new server...'"

# Copy our log script over so that other scripts can call it.
{{ pillar.tm_dir}}/log.sh:
  file.managed:
    - source: salt://log.sh
    - mode: "755"