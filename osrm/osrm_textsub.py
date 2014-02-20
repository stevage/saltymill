#!/usr/bin/python
import os, sys, re
os.rename('OSRM.config.js', 'OSRM.config.js.orig')
# In the process we convert line endings for some reason. :/
with open('OSRM.config.js.orig', 'r') as fin, open('OSRM.config.js', 'w') as fout:
    data = fin.read()
    
    data = re.sub(r'(ROUTING_ENGINES: \[).*?(\s+\],)', r'\1\n' +
    {% for instance in pillar.tm_osrminstances %}
      '''{
        url: "http://{{ grains.fqdn }}:{{ instance.port }}/viaroute",
        timestamp:  "http://{{ grains.fqdn }}:{{ instance.port}}/timestamp",
        metric: 1,
        label: "{{ instance.name }}",
      }, '''
    {% endfor %}
      r'\2\n', data, flags=re.DOTALL)
    {% if pillar.tm_osrmlayers is defined %}
    data = re.sub(r'(TILE_SERVERS: \[).*?(\s+\],)', r'\1\n' +
    """{{ pillar.tm_osrmlayers }}""" + 
      r'\2\n', data, flags=re.DOTALL)
    {% endif %}
    fout.write(data)
