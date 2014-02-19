# This is a minimal install. Copy this file over /srv/tm.sls

tm_username: tm                       # Username/password for basic htpasswd authentication
tm_password: pumpkin                  
tm_timezone: 'Australia/Melbourne'    # We set the timezone because NeCTAR VMs don't have it set.
tm_dir: /mnt/saltymill                # Where to install scripts to.
