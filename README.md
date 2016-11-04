# epas_and_vagrant

Simple script for EDB Postgres Advanced Server 9.5 on CentOS 7

## Why is this necessary?
In using Docker, automation when using Postgres with a CentOS7 image encounters idiosyncrasies that prevent connections to the database without human intervention (because of systemd and DBus compatibilities issues).  Using Vagrant in this case will allow users to set up an EPAS 9.5 instance on CentOS 7

## How to use this?
This is designed such that you can access the database by simply executing the following steps:

1. Edit `epas95_build.sh` with correct EDB Yum username/password credentials
1. `vagrant up`
1. `vagrant ssh`
1. `psql -c "SELECT version()"`
