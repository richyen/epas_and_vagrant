#!/bin/bash

### Script to set up EFM
### Assumes epas_build.sh has already been run

EFM_VER=3.9

yum install -y which efm-${EFM_VER} java-1.8.0-openjdk

mkdir -p /opt/backup
mkdir -p /var/lib/ppas/${PGMAJOR}/wal_archive
chown -R enterprisedb:enterprisedb /var/lib/ppas
chown enterprisedb:enterprisedb /opt/backup

cp /vagrant/efm.properties /etc/edb/efm-${EFM_VER}/efm.properties
cp /etc/efm-${EFM_VER}/efm.nodes.in /etc/efm-${EFM_VER}/efm.nodes
