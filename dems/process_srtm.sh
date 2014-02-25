if [ "$1" == "" ]; then
  echo "Usage: process_srtm.sh <base>"
  echo "where files to merge and process are called <base>_*.tif"
  exit 1
fi
f=$1
rm -f $f.tif $f-3785*
echo -n "Merging files: "
gdal_merge.py ${f}_*.tif -o ${f}.tif
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
