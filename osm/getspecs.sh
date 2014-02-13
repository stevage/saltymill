#!/bin/bash
# We tune Postgres to use 1/4 of available memory.
export MYMEM=$(free -g --si | awk  '/^Mem:/{print $2}')
#Or override it.
#MYMEM=32
export MYCORES=$(grep -c ^processor /proc/cpuinfo)      # Not currently used
