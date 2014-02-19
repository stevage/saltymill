include:
  - .tilemillinstall
    {% if pillar.tm_fonts is defined %}
  - .fonts
    {% endif %}
    {% if pillar.tm_waterpolygonsource is defined %}
  - .waterpolygons
    {% endif %}
    {% if pillar.tm_projects is defined %}
  - .projects
    {% endif %}
  