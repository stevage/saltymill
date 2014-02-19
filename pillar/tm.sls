# Copy top.sls and tm.sls to /srv/pillar, then change the settings below.

tm_username: tm                       # Username/password for basic htpasswd authentication
tm_password: pumpkin                  
tm_timezone: 'Australia/Melbourne'    # We set the timezone because NeCTAR VMs don't have it set.
tm_dir: /mnt/saltymill                # Where to install scripts to.
tm_dev: False                         # Install the development version of TileMill. This has newer features 
                                      # but may be less stable. No stock sample projects included. Also much
                                      # slower to build, as it must be compiled from source.


tm_fonts:       # List of urls that provide zip downloads
  - http://www.freefontspro.com/d/12524/cartogothic_std.zip
  - http://www.fontsquirrel.com/fonts/download/roboto

# (Optional)
tm_waterpolygonsource: http://gis.researchmaps.net/water-polygons-split-3857.zip

# (Optional)
tm_projects:
                                      # Sample projects to unzip in /usr/share/mapbox/project. Name required but not used for much.
  - { name: mapstarter, source: "http://gis.researchmaps.net/sample/map-starter.zip" }
  #- { name: melbourne, source: http://gis.researchmaps.net/sample/melbourne.zip } 

# OpenStreetMap/PostGIS settings

tm_dbusername: ubuntu                 # Postgres username/password that will be created
tm_dbpassword: ubuntu                 # and used to load data with. It doesn't get external access.
tm_postgresdir: /mnt/var/lib          # Directory to move Postgres to (ie, big, non-ephemeral drive).
                                      # OSM extract source. Comment out to skip all OSM stuff.
# For a quick test build, try 
tm_osmsourceurl: http://download.geofabrik.de/asia/azerbaijan-latest.osm.pbf
# For the full Australian extract (adds an hour or so to the build time): 
# tm_osmsourceurl: http://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf

# (Optional: the Open Source Routing Machine)
# NB: OSRM instances require a lot of memory, most of which has been allocated to Postgres.
tm_osrminstances:                     # If no instances, OSRM doesn't get installed.
  - { name: Bike, port: 5010, profile: bicycle }
  # - { name: Walking, port: 5011, profile: foot }
  # name: Text displayed in the OSRM web interface
  # port: The port OSRM listens on for this instances
  # profile: The included .lua file (one of car, foot, bicycle )
  # profilesource (optional, untested): URL to download a different .lua file from http://...
tm_osrmdir: /mnt/saltymill/osrm
