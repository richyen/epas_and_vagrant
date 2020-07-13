#!/bin/bash

### Script to install and configure XDB 6.x
### Assumes epas_build.sh has already been run

# set up XDB6
XDB_VERSION=6.2
INSTALLDIR=/usr/ppas-xdb-${XDB_VERSION}
JAVA_VERSION=1.8

yum -y install ppas-xdb which java-${JAVA_VERSION}.0-openjdk-devel

# tweak conf files so logical replication can happen
sed -e "s/^wal_level.*/wal_level = logical/" \
    -e "s/^log_line_prefix.*/log_line_prefix = '%m [user=%u,db=%d %r APP=%a PID=%p XID=%x]'/" \
    -e "s/^#max_replication_slots.*/max_replication_slots = 5/" -i ${PGDATA}/postgresql.conf
echo "host replication enterprisedb 0.0.0.0/0 trust" >> ${PGDATA}/pg_hba.conf

cp /vagrant/edb-repl.conf /etc/edb-repl.conf
chown enterprisedb:enterprisedb /etc/edb-repl.conf && \
chmod 600 /etc/edb-repl.conf
cp /vagrant/xdb_repsvrfile.conf ${INSTALLDIR}/etc/xdb_repsvrfile.conf

# saving this in case I want to make an SMR version of this later
cp /vagrant/xdb_repsvrfile.conf ${INSTALLDIR}/etc/xdb_subsvrfile.conf
sed -i "s/9051/9052/" ${INSTALLDIR}/etc/xdb_subsvrfile.conf
