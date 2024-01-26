# Deployment & Demo prep

1. Create network environment using `./00-pgd-network-configuration.sh`
2. Create peering between regions using `./01-create_peering_connections.sh`
3. Create routing tables using `./02-create_routes.sh`
4. Create EC2 instances using `./03-configure_and_provision_pgd_multiregion_aws.sh`
5. Fix subnet association using `./05_deploy_pgd_multiregion_aws.sh`
6. Deploy PGD using `./05_deploy_pgd_multiregion_aws.sh`
7. Transfer demo scripts over to all nodes using `./06_copy_files_to_aws.sh`

# Demo flow

[1. Switchover](./scripts/01-switchover/Switchover.md)

[2. Failover](./scripts/02-failover/Failover.md)

[4. Conflicts](./scripts/04-conflicts/Conflicts.md)

[5. Transparent Data Encryption](./scripts/07-tde/TDE.md)

[6. Upgrades](./scripts/06-upgrades/Upgrades.md)

[7. Failed node replacement](./scripts/07-failed-node/Failed-node.md)

[8. Group commits](./scripts/08-group-commits/Commitgroups.md)

[9. Selective replication](./scripts/06-selective_replication/Selective-replication.md)

[10. pgBouncer](./scripts/10-pgBouncer/pgBouncer.md)