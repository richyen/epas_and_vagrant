One-shot EFM cluster done like so:

* Edit `epas95_efm2_build.sh` with YUM credentials
* `vagrant up`
* `vagrant ssh master`

And with `sudo /usr/efm-2.0/bin/efm cluster-status efm` you should get:
```
[vagrant@master vagrant]# sudo /usr/efm-2.0/bin/efm cluster-status efm
Cluster Status: efm

	Agent Type  Address              Agent  DB       Info
	--------------------------------------------------------------
	Master      10.0.3.100           UP     UP        
	Witness     10.0.3.102           UP     N/A       
	Standby     10.0.3.101           UP     UP        

Allowed node host list:
	10.0.3.100 10.0.3.101 10.0.3.102

Standby priority host list:
	10.0.3.102 10.0.3.101

Promote Status:

	DB Type     Address              XLog Loc         Info
	--------------------------------------------------------------
	Master      10.0.3.100           0/4000B30        
	Standby     10.0.3.101           0/4000B68        

	One or more standby databases are not in sync with the master database.
```
