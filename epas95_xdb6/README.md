One-shot EFM cluster done like so:

* Edit `epas95_xdb6_build.sh` with YUM credentials
* Set the number of desired nodes (including MDN) in `Vagrantfile`
* `vagrant up`

From here, you should see an XDB6 MMR cluster build, followed by verification that replication is functional.
