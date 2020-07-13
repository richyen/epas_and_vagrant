#!/bin/bash

num_nodes=${1}
if [[ "x${num_nodes}" == "x" ]]
then
  num_nodes=2
fi

# Make these IPs available for other scripts
export MDN_IP=`hostname -i`
export OTHER_MASTER_IPS=`seq -s " " -f"10.0.3.10%g" 1 $(( num_nodes - 1 ))`

# Start xDB
rm -f /var/run/edb/xdbpubserver/edb-xdbpubserver.pid
rm -f /var/run/edb-xdbpubserver/edb-xdbpubserver.pid # handle legacy bug
systemctl enable edb-xdbpubserver
systemctl start edb-xdbpubserver

# Load data into MDN
pgbench -h ${MDN_IP} -i edb
# psql -h ${MDN_IP} -c "ALTER TABLE pgbench_history add primary key (tid,bid,aid,delta,mtime)" edb

# Make sure pubserver is running
sleep 5 # because exit code for the below command isn't 0 (yet) in case of error
java -jar /usr/ppas-xdb-6.0/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-6.0/etc/xdb_repsvrfile.conf -uptime

# Build xDB replication infrastructure
java -jar /usr/ppas-xdb-6.0/bin/edb-repcli.jar -addpubdb -repsvrfile /usr/ppas-xdb-6.0/etc/xdb_repsvrfile.conf -dbtype enterprisedb -dbhost ${MDN_IP} -dbuser enterprisedb -dbpassword `cat /usr/ppas-xdb-6.0/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype m -nodepriority 1 -dbport 5432 -changesetlogmode W
java -jar /usr/ppas-xdb-6.0/bin/edb-repcli.jar -createpub xdbtest -repsvrfile /usr/ppas-xdb-6.0/etc/xdb_repsvrfile.conf -pubdbid 1 -reptype T -tables public.pgbench_accounts public.pgbench_branches public.pgbench_tellers -repgrouptype M -standbyconflictresolution 1:E 2:E 3:E

# Add other masters
for i in ${OTHER_MASTER_IPS}
do
    java -jar /usr/ppas-xdb-6.0/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-6.0/etc/xdb_repsvrfile.conf -addpubdb -dbtype enterprisedb -dbhost ${i} -dbuser enterprisedb -dbpassword `cat /usr/ppas-xdb-6.0/etc/xdb_repsvrfile.conf | grep pass | cut -f2- -d'='` -database edb -repgrouptype m -dbport 5432 -initialsnapshot -replicatepubschema true -changesetlogmode W
done

# Create Schedule
java -jar /usr/ppas-xdb-6.0/bin/edb-repcli.jar -repsvrfile /usr/ppas-xdb-6.0/etc/xdb_repsvrfile.conf -confschedulemmr basic_schedule -pubname xdbtest -realtime 5

# Test Replication
echo "MDN value:"
psql -c "select filler from pgbench_accounts where aid = 10"
for i in ${OTHER_MASTER_IPS}
do
  psql -h ${i} -c "select '${i}' as host, filler from pgbench_accounts where aid = 10"
done
psql -c "update pgbench_accounts set filler = md5(random()) where aid = 10"
sleep 10
echo "MDN value:"
psql -c "select filler from pgbench_accounts where aid = 10"
for i in ${OTHER_MASTER_IPS}
do
  psql -h ${i} -c "select '${i}' as host, filler from pgbench_accounts where aid = 10"
done
