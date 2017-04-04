#!/bin/bash

# This script to be run on the master database
# Need to make sure application_name is set correctly in standby's recovery.conf

PGMAJOR=9.5
PGDATA="/var/lib/ppas/${PGMAJOR}/data"

sed -i "s/^#synchronous_standby_names.*/synchronous_standby_names = 'db1'/" ${PGDATA}/postgresql.conf
sudo systemctl restart ppas-${PGMAJOR}.service
