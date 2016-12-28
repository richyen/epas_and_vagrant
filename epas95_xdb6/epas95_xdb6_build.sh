#!/bin/bash
YUMUSERNAME=""
YUMPASSWORD=""
PGMAJOR=9.5
PGPORT=5432
PGDATABASE=edb
PGUSER=enterprisedb
PATH=/usr/ppas-${PGMAJOR}/bin:${PATH}
PGDATA=/var/lib/ppas/${PGMAJOR}/data
PGLOG=/var/lib/ppas/${PGMAJOR}/pgstartup.log

rpm -ivh http://yum.enterprisedb.com/edbrepos/edb-repo-9.6-3.noarch.rpm
sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo

yum -y update
yum --enablerepo=ppas95 -y install ppas95-server.x86_64 net-tools sudo

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

sudo echo "local  all         all                      trust" >  ${PGDATA}/pg_hba.conf
sudo echo "local  replication all                      trust" >> ${PGDATA}/pg_hba.conf
sudo echo "host   replication enterprisedb  0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf
sudo echo "host   all         all           0.0.0.0/0  trust" >> ${PGDATA}/pg_hba.conf

sudo sed -i "s/^#port = .*/port = ${PGPORT}/"         ${PGDATA}/postgresql.conf
sudo sed -i "s/^port = .*/port = ${PGPORT}/"         ${PGDATA}/postgresql.conf
sudo sed -i "s/^logging_collector = off/logging_collector = on/" ${PGDATA}/postgresql.conf                                                                                  
sudo sed -i "s/^#wal_keep_segments = 0/wal_keep_segments = 500/" ${PGDATA}/postgresql.conf
sudo sed -i "s/^#max_wal_senders = 0/max_wal_senders = 5/" ${PGDATA}/postgresql.conf
sudo sed -i "s/^#wal_level.*/wal_level = logical/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
sudo sed -i "s/^#max_replication_slots.*/max_replication_slots = 5/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf
sudo sed -i "s/^#track_commit_timestamp.*/track_commit_timestamp = on/" /var/lib/ppas/${PGMAJOR}/data/postgresql.conf

sudo systemctl enable ppas-${PGMAJOR}.service
sudo systemctl start ppas-${PGMAJOR}.service

# set up XDB6
yum --enablerepo=enterprisedb-xdb60 --enablerepo=enterprisedb-dependencies -y install ppas-xdb which java-1.7.0-openjdk-devel

XDB_INSTALLDIR='/usr/ppas-xdb-6.0'
cp /vagrant/build_xdb_mmr_publication.sh ${XDB_INSTALLDIR}
cp /vagrant/edb-repl.conf /etc/edb-repl.conf
chown enterprisedb:enterprisedb /etc/edb-repl.conf
chmod 600 /etc/edb-repl.conf
cp /vagrant/xdb_repsvrfile.conf ${XDB_INSTALLDIR}/etc/xdb_repsvrfile.conf

# saving this in case I want to make an SMR version of this later
cp /vagrant/xdb_repsvrfile.conf ${XDB_INSTALLDIR}/etc/xdb_subsvrfile.conf
sed -i "s/9051/9052/" ${XDB_INSTALLDIR}/etc/xdb_subsvrfile.conf
