# Copy top.sls and tm.sls to /srv/pillar, then change the settings below.

# After editing, run:
# salt-call --local state.highstate

# Indentation matters! 

base:
  '*':
    - tm
    # - workshops
    - logging