#!/bin/bash
pkill -f 'osrm-routed.*-p {{ port }}'
sleep 2
nohup ./osrm-routed -p {{ port }} -t 8 extract.osrm &
