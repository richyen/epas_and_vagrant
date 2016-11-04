#!/bin/bash
YUMUSERNAME=""
YUMPASSWORD=""
REPONAME=ppas95
PGMAJOR=9.5
PGPORT=5432
PGDATABASE=edb
PGUSER=enterprisedb
PATH=/usr/ppas-${PGMAJOR}/bin:${PATH}
PGDATA=/var/lib/ppas/${PGMAJOR}/data
PGLOG=/var/lib/ppas/${PGMAJOR}/pgstartup.log

rpm -ivh http://yum.enterprisedb.com/reporpms/${REPONAME}-repo-${PGMAJOR}-1.noarch.rpm
sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/${REPONAME}.repo

yum -y update
yum -y install ${REPONAME}-server.x86_64 net-tools sudo

echo 'root:root'|chpasswd

# setting postgres user for login
adduser --home-dir /home/postgres --create-home postgres
echo 'postgres   ALL=(ALL)   NOPASSWD: ALL' >> /etc/sudoers
echo 'postgres:postgres'|chpasswd

sudo -u enterprisedb /usr/ppas-${PGMAJOR}/bin/initdb -D ${PGDATA}

sudo sed -i "s/^PGPORT.*/PGPORT=${PGPORT}/" /etc/sysconfig/ppas/ppas-${PGMAJOR}

sudo echo "export PGPORT=${PGPORT}"         >> /etc/profile.d/pg_env.sh
sudo echo "export PGDATABASE=${PGDATABASE}" >> /etc/profile.d/pg_env.sh
sudo echo "export PGUSER=${PGUSER}"         >> /etc/profile.d/pg_env.sh
sudo echo "export PATH=${PATH}"             >> /etc/profile.d/pg_env.sh

sudo echo "local  all         all                 trust" >  ${PGDATA}/pg_hba.conf
sudo echo "local  replication all                 trust" >> ${PGDATA}/pg_hba.conf
sudo echo "host   replication repuser  0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf
sudo echo "host   all         all      0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf

sudo sed -i "s/^#port = .*/port = ${PGPORT}/"         ${PGDATA}/postgresql.conf
sudo sed -i "s/^port = .*/port = ${PGPORT}/"         ${PGDATA}/postgresql.conf
sudo sed -i "s/^logging_collector = off/logging_collector = on/" ${PGDATA}/postgresql.conf                                                                                  
sudo sed -i "s/^#wal_level.*/wal_level=hot_standby/" ${PGDATA}/postgresql.conf
sudo sed -i "s/^#wal_keep_segments = 0/wal_keep_segments = 500/" ${PGDATA}/postgresql.conf
sudo sed -i "s/^#max_wal_senders = 0/max_wal_senders = 5/" ${PGDATA}/postgresql.conf

sudo systemctl enable ppas-${PGMAJOR}.service
sudo systemctl start ppas-${PGMAJOR}.service

psql -p ${PGPORT} -c "CREATE USER repuser REPLICATION" ${PGDATABASE} ${PGUSER}
