#!/bin/bash

NODE_NUM=${1}
PGMAJOR=10

# Script to be run on to-be standby
MASTER_HOST=10.0.3.100
ARCHIVE_DIR="/var/lib/ppas/${PGMAJOR}/wal_archive"
DATADIR="/var/lib/ppas/${PGMAJOR}/data"

# Make sure repuser exists already
if [[ `psql -h ${MASTER_HOST} -Atc "SELECT count(*) FROM pg_shadow WHERE usename = 'repuser'" edb enterprisedb` -eq 0 ]]
then
  psql -h ${MASTER_HOST} edb enterprisedb -c "CREATE USER repuser REPLICATION"
fi
  
# Stop existing local postgres service
service ppas-${PGMAJOR} stop

# Create archive_dir for archive_command
rm -rf ${ARCHIVE_DIR}
mkdir -p ${ARCHIVE_DIR}
chmod 700 ${ARCHIVE_DIR}
chown -R enterprisedb:enterprisedb ${ARCHIVE_DIR}

# Create $PGDATA
rm -rf ${DATADIR}
mkdir -p ${DATADIR}

# Perform base backup
pg_basebackup -U repuser -h ${MASTER_HOST} -D ${DATADIR} -xPR

# Fix up confs so that this machine is a valid EFM standby
sed -i "s/'user/'application_name=db${NODE_NUM} user/" ${DATADIR}/recovery.conf
echo "trigger_file='/tmp/efm_standby_trigger'" >> ${DATADIR}/recovery.conf
if [[ `grep -c "^hot_standby" ${DATADIR}/postgresql.conf` -gt 0 ]]
then
    sed -i "s/^hot_standby.*/hot_standby = on/" ${DATADIR}/postgresql.conf
else
    echo "hot_standby = on" >> ${DATADIR}/postgresql.conf
fi

# more cleanup
chown -R enterprisedb:enterprisedb ${DATADIR}
chmod 700 ${DATADIR}

# Start postgres
service ppas-${PGMAJOR} start
