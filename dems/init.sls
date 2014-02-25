# "Where <lat1,2> are 1-24, <lon1,2> are 1-71, tile numbers as per http://srtm.csi.cgiar.org/SELECTION/inputCoord.asp"

demdirs:
  file.directory:
    - names: [ {{ pillar.tm_demdir }}, {{ pillar.tm_demdir }}/vic ]
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
  cmd.script:
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
    - name: |
        wget -nv {{pillar.tm_vicdem_source}}dtm20m_ext_vg94.zip
        unzip dtm20m_ext_vg94.zip
        wget -nv {{pillar.tm_vicdem_source}}dtm20m-3785-hs-cut.tif
        # Source files, not needed by me as I have the processed (hs-cut) one available.
        #wget -nv {{pillar.tm_vicdem_source}}vmelev_dtm20m.zip
        # 10m extent file, not needed by me as not using 10m.
        #wget -nv {{pillar.tm_vicdem_source}}dtm10m_ext_vg94.shp
        #yes no | unzip '*.zip'
    - unless: test -f dtm20m-3785-hs-cut.tif
# Similarly need to sort this out.
getcontours:
  cmd.run:
    - cwd: {{ pillar.tm_demdir }}
    - user: ubuntu
    - group: ubuntu
    - name: |
        wget -nv http://gis.researchmaps.net/process-dems/se-aust-contours.zip
        unzip se-aust-contours.zip
    - unless: test -f se-aust-contours.zip