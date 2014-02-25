# "Where <lat1,2> are 1-24, <lon1,2> are 1-71, tile numbers as per http://srtm.csi.cgiar.org/SELECTION/inputCoord.asp"

{{ pillar.tm_demdir }}:
  file.directory:
    - makedirs: True
    - user: ubuntu
    - group: ubuntu

getdems:
  pkg.installed: 
    - name: unzip
  cmd.run:
    - cwd: {{ pillar.tm_demdir }}
    - user: ubuntu
    - group: ubuntu
    - name: |
        changed="no"
        for x in {{'{' ~ pillar.tm_srtm_x1 ~ '..' ~ pillar.tm_srtm_x2 ~ '}'}}; do
        for y in {{'{' ~ pillar.tm_srtm_y1 ~ '..' ~ pillar.tm_srtm_y2 ~ '}'}}; do
        if [ ! -f srtm_${x}_${y}.zip ]; then
          #wget -nv http://droppr.org/srtm/v4.1/6_5x5_TIFs/srtm_${x}_${y}.zip
          wget -nv {{pillar.tm_srtm_source}}srtm_${x}_${y}.zip
          changed="yes"
          rm -f srtm.tif
        fi
        done
        done
        if [ $changed == "yes" ]; then yes no | unzip '*.zip'; fi
        echo
        echo "changed=$changed"
    #- stateful: True

gdal:
  pkg.installed:
    - names: [ gdal-bin, python-gdal ]

dodems:
  script.run:
    - cwd: {{ pillar.tm_demdir }}
    - user: ubuntu
    - group: ubuntu
    - source: salt://./process_srtm.sh
    - args: "srtm"
    - watch: [ cmd: getdems ]
    - require: [ pkg: gdal ]
    - unless: test -f srtm.tif
    - onlyif: test "`ls srtm_*.tif`"

# Should clean these up to somewhere else maybe.
getvicdems:
  pkg.installed: 
    - name: unzip
  cmd.run:
    - cwd: {{ pillar.tm_demdir }}/vic
    - user: ubuntu
    # For reference only, the hs-cut file is produced with 
    # gdalwarp -co "BIGTIFF=YES" -dstalpha -cutline dtm20m_ext_vg94.shp dtm20m-3785-hs.tif dtm20m-3785-hs-cut.tif
    - group: ubuntu
        #wget -nv {{pillar.tm_vicdem_source}}vmelev_dtm20m.zip
        wget -nv {{pillar.tm_vicdem_source}}dtm20m_ext_vg94.shp
        wget -nv {{pillar.tm_vicdem_source}}dtm20m_ext_vg94.shp
        wget -nv {{pillar.tm_vicdem_source}}dtm20m-3785-hs-cut.tif
        #yes no | unzip '*.zip'
    - unless: test -f dtm20m-3785-hs-cut.tif