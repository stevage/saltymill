# "Where <lat1,2> are 1-24, <lon1,2> are 1-71, tile numbers as per http://srtm.csi.cgiar.org/SELECTION/inputCoord.asp"

{{ pillar.tm_demdir }}:
  file.directory
    - makedirs: True
    - user: ubuntu
    - group: ubuntu


getdems:
  cmd.run:
    - cwd: {{ pillar.tm_demdir }}
    - user: ubuntu
    - group: ubuntu
    - name: |
        changed="no"
        for x in {{'{' ~ pillar.tm_srtm_x1 ~ '..' ~ pillar.tm_srtm_x2 ~ '}'}}; do
        for x in {{'{' ~ pillar.tm_srtm_y1} ~ '..` ~ pillar.tm_srtm_y2 ~ '}'}}; do
        #echo $x,$y
        if [ ! -f srtm_${x}_${y}.zip ]; then
          wget -nv http://droppr.org/srtm/v4.1/6_5x5_TIFs/srtm_${x}_${y}.zip
          changed="yes"
        fi
        done
        done
        if [ changed == "yes"]; then unzip '*.zip'; fi
        echo
        echo "changed=$changed"
    - stateful: True

dodems:
  pkg.installed:
    - name: gdal-bin
  cmd.wait:
      - cwd: {{ pillar.tm_demdir }}
      - user: ubuntu
      - group: ubuntu
      - name: |
          #!/bin/bash
          echo -n "Merging files: "
          gdal_merge.py srtm_*.tif -o srtm.tif
          f=srtm
          echo -n "Re-projecting: "
          gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear $f.tif $f-3785.tif 

          echo -n "Generating hill shading: "
          #TODO install dev version of gdal in order to use -combined option.
          gdaldem hillshade -z 5 $f-3785.tif $f-3785-hs.tif
          echo and overviews:
          gdaladdo -r average $f-3785-hs.tif 2 4 8 16 32


          echo -n "Generating slope files: "
          gdaldem slope $f-3785.tif $f-3785-slope.tif 
          echo -n "Translating to 0-90..."
          gdal_translate -ot Byte -scale 0 90 $f-3785-slope.tif $f-3785-slope-scale.tif
          echo "and overviews."
          gdaladdo -r average $f-3785-slope-scale.tif 2 4 8 16 32
            
          echo -n Translating DEM...
          gdal_translate -ot Byte -scale -10 2000 $f-3785.tif $f-3785-scale.tif 
          echo and overviews.
          gdaladdo -r average $f-3785-scale.tif 2 4 8 16 32

          #echo Creating contours
          #gdal_contour -a elev -i 20 $f-3785.tif $f-3785-contour.shp
    - watch: [ cmd getdems ]