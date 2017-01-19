One-shot PEM cluster done like so:

* Download PEM Server `.run` installer into same dir as `Vagrantfile`
* Fill in EDB Customer Portal credentials into `build_pemserver.sh`
* Fill in EDB YUM repo credentials into `build_pemagent.sh`
* Set the number of desired nodes in `Vagrantfile`
* `vagrant up`

From here, you should see PEM 6 Server build, a number of VMs that will run PEM Agents, followed by a launch of the PEM Web Console.  You can view the PEM Web Console at `https://10.0.3.100:8443/pem` -- log in with username/password `postgres` and `abc123`
