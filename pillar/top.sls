# Copy top.sls and tm.sls to /srv/pillar, then change the settings below.

# Indentation matters! 

base:
  '*':
    - tm
    # - workshops