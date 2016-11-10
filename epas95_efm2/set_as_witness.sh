#!/bin/bash

echo 10.0.3.100:5430 10.0.3.101:5430 >> /etc/efm-2.0/efm.nodes

sed -i "s/is.witness=.*/is.witness=true/" /etc/efm-2.0/efm.properties
sed -i "s/bind.address.*/bind.address=10.0.3.102:5430/" /etc/efm-2.0/efm.properties

service efm-2.0 start
