#!/bin/bash

### Script to install EDB Postgres Advanced Server

### NOTE: the following vars should be passed via Vagrantfile:
###   - PGMAJOR
###   - OSVER
###   - YUMUSERNAME
###   - YUMPASSWORD

PGPORT=5432
PGDATABASE=edb
PGUSER=enterprisedb
PATH=/usr/edb/as-${PGMAJOR}/bin:${PATH}
PGDATA=/var/lib/edb/as${PGMAJOR}/data
PGLOG=/var/lib/edb/as${PGMAJOR}/pgstartup.log

rpm -ivh https://yum.enterprisedb.com/edbrepos/edb-repo-latest.noarch.rpm
sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo

yum -y update
yum -y install yum-plugin-ovl epel-release
yum -y install edb-as${PGMAJOR/./}-server.x86_64 sudo

echo 'root:root'|chpasswd

if [[ ${OSVER} -eq 6 ]]; then
  service edb-as-${PGMAJOR} initdb
  sed -i "s/^PGPORT.*/PGPORT=${PGPORT}/" /etc/sysconfig/edb/as${PGMAJOR}/edb-as-${PGMAJOR}.sysconfig
else
  su - enterprisedb -c "/usr/edb/as${PGMAJOR}/bin/initdb -D ${PGDATA}"
fi

echo "export PGPORT=${PGPORT}"         >> /etc/profile.d/pg_env.sh && \
echo "export PGDATABASE=${PGDATABASE}" >> /etc/profile.d/pg_env.sh && \
echo "export PGUSER=${PGUSER}"         >> /etc/profile.d/pg_env.sh && \
echo "export PATH=${PATH}"             >> /etc/profile.d/pg_env.sh

echo "local  all         all                 trust" >  ${PGDATA}/pg_hba.conf && \
echo "local  replication all                 trust" >> ${PGDATA}/pg_hba.conf && \
echo "host   replication repuser  0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf && \
echo "host   all         all      0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf

sed -e "s/^port = .*/port = ${PGPORT}/" \
    -e "s/^logging_collector = off/logging_collector = on/" \
    -e "s/^#wal_level.*/wal_level=hot_standby/" \
    -e "s/^#wal_keep_segments = 0/wal_keep_segments = 500/" \
    -e "s/^#max_wal_senders = 0/max_wal_senders = 5/" -i ${PGDATA}/postgresql.conf

if [[ ${OSVER} -eq 6 ]]; then
  sudo service edb-as-${PGMAJOR} start
else
  sudo systemctl enable edb-as-${PGMAJOR}.service
  sudo systemctl start edb-as-${PGMAJOR}.service
fi
