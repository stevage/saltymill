include:
    {% if pillar.tm_fonts is defined %}
    # Get fonts first so they are seen by TileMill. (Alternative: restart tilemill)
  - .fonts
    {% endif %}
  - .tilemillinstall
    {% if pillar.tm_waterpolygonsource is defined %}
  - .waterpolygons
    {% endif %}
    {% if pillar.tm_projects is defined %}
  - .projects
    {% endif %}
  