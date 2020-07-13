#!/bin/bash

sed -i "s/bind.address.*/bind.address=10.0.3.100:5430/" /etc/efm-2.0/efm.properties
service efm-2.0 start

/usr/efm-2.0/bin/efm add-node efm 10.0.3.101 1
/usr/efm-2.0/bin/efm add-node efm 10.0.3.102 1
