#!/bin/bash

AGENT_ID=${1}
YUMUSERNAME=''
YUMPASSWORD=''

# Install required packages
sudo yum -y install epel-release
sudo rpm -ivh http://yum.enterprisedb.com/edbrepos/edb-repo-9.6-3.noarch.rpm
sudo sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/edb.repo
sudo yum --enablerepo=enterprisedb-tools --enablerepo=ppas95 --enablerepo=enterprisedb-dependencies -y install which ppas95-server-sslutils openssl-devel pem-agent

# Configure agent
sudo cp /usr/pem-6.0/etc/agent.cfg.sample /usr/pem-6.0/etc/agent.cfg
sudo sed -i "s/pem_host=.*/pem_host=10.0.3.100/" /usr/pem-6.0/etc/agent.cfg
sudo sed -i "s/pem_port=.*/pem_port=5432/" /usr/pem-6.0/etc/agent.cfg
sudo sed -i "s/agent_id=.*/agent_id=${AGENT_ID}/" /usr/pem-6.0/etc/agent.cfg

# Register agent
PGPASSWORD=abc123 /usr/pem-6.0/bin/pemworker --register-agent --pem-server 10.0.3.100 --pem-user postgres --display-name pemagent${AGENT_ID}
sudo systemctl restart pemagent
