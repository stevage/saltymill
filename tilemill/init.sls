include:
  - .tilemillinstall
  - .fonts
  {% if pillar.tm_waterpolygonsource is defined %}
  - .waterpolygons
  {% endif %}
  - .projects
