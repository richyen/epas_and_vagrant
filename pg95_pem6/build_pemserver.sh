#!/bin/bash

EDBUSERNAME=''
EDBPASSWORD=''

sudo mkdir -p /opt/languagepack
sudo mkdir -p /opt/apache-httpd
sudo mkdir -p /opt/postgresql

# Place all necessary files for PEM Server installation
INSTALLER_FILENAME=`ls /vagrant | grep run | grep -i pem | grep -i server`
sudo cp /vagrant/${INSTALLER_FILENAME} /tmp/${INSTALLER_FILENAME}
sudo chmod 755 /tmp/${INSTALLER_FILENAME}
sudo sed -i "s/existing-user=.*/existing-user=${EDBUSERNAME}/" /vagrant/pem_install_optionfile
sudo sed -i "s/existing-password=.*/existing-password=${EDBPASSWORD}/" /vagrant/pem_install_optionfile

# Extract Python dependencies
sudo /tmp/${INSTALLER_FILENAME}  --extract-languagepack /opt/languagepack --extract-apache-httpd /opt/apache-httpd --extract-postgresql /opt/postgresql

# Install dependencies and PEM Server
sudo /opt/languagepack/`ls /opt/languagepack` --mode unattended --prefix /usr/edb-languagepack
sudo /opt/apache-httpd/`ls /opt/apache-httpd` --mode unattended --prefix /usr/edb-apache-httpd
sudo /opt/postgresql/`ls /opt/postgresql` --mode unattended --prefix /usr/pgsql-9.5

# Make demo deployment easier
sudo sed -i "s/md5/trust/" /opt/PostgreSQL/9.5/data/pg_hba.conf
sudo sed -i "s/32/0/" /opt/PostgreSQL/9.5/data/pg_hba.conf
sudo systemctl reload postgresql-9.5.service
sudo /usr/pgsql-9.5/bin/psql -c "ALTER USER postgres WITH PASSWORD 'abc123'" -U postgres

# Install PEM Server
sudo /tmp/${INSTALLER_FILENAME} --mode unattended --optionfile /vagrant/pem_install_optionfile

echo "You may now open the PEM Server Web Console at https://10.0.3.100:8443/pem/"
