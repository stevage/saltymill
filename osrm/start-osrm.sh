#!/bin/bash
pkill -f 'osrm-routed.*-p {{ port }}'
sleep 2
./osrm-datastore extract.osrm
nohup ./osrm-routed -p {{ port }} -t 8 --sharedmemory yes &
