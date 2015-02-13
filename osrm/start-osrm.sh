#!/bin/bash
nohup ./osrm-routed -p {{ port }} -t 8 extract.osrm &
