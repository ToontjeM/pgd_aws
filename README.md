# Deployment
- Install VirtualBox and Vagrant
- `vagrant up`
- `vagrant ssh`
In directory `/vagrant`
- Install AWS CLI using `./pre-install_aws_cli.sh` ✓
- Install tpaexec using `./pre-install_tpaexec.sh` ✓
- Export your AWS credentials to the current console ✓
- Deploy network using `./00-pgd-network-configuration.sh` ✓
- Create peering connections using `./01-create_peering_connections.sh` ✓
  - ohio - virginia
  - ohio - oregon
  - virginia - oregon
  - virginia - ohio
  - oregon - virginia
  - oregon - ohio
- Route tables add subnets using `./02-create_routes.sh` ✓
  - oregon
  - ohio
  - virginia
- Deploy Multi-region PGD using `03-configure_and_provision_pgd_multiregion_aws.sh` ✓
  - This will reconfigure the routing table associantions
- Associate subnets to the old route table (sro-pgdnetwork) using `./04-subnet-associention.sh` ✓
  - Oregon
  - Ohio
  - Virginia
- Deploy PGD using `05_deploy_pgd_multiregion_aws.sh` ✓

# Demo prep
- Copy demo files to EC2 instances using `06_copy_files_to_aws.sh`
- On each EC2 instance, run:
  - `sudo su - enterprisedb`
  - `cd`
  - `cp -r /tmp/* .`

# Demo flow

