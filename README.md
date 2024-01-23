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
- Divide screen into 4 panes and into each pane:
  - `cd ~/sro-pgdcluster-mr`
  In TL (Top Left) pane: `ssh -F ssh_config barman-uswest2`
  In TR (Top Right) pane:`ssh -F ssh_config barman-useast2`
  In BL (Bottom Left) pane: `ssh -F ssh_config barman-useast2`
  In BR (Bottom Right) pane: `ssh -F ssh_config pgd1-useast2`
  In all panes: `sudo cp -r /tmp/* .`

# Demo flow

### 01-Switchover
- BR: Create table `ping` using `./01_create_table.sh`
- BL: 
  `pgd bdrdb`
  `\dt`
  ```          
  List of relations
  Schema | Name | Type  |    Owner
  --------+------+-------+--------------
  public | ping | table | enterprisedb
  (1 row)
  ```
  
  `select * from ping order by timestamp desc limit 10; \watch 1`

  ```
  Tue Jan 23 15:18:50 2024 (every 1s)

  id | node | timestamp
  ----+------+-----------
  (0 rows)

  Tue Jan 23 15:18:51 2024 (every 1s)

   id | node | timestamp
  ----+------+-----------
  (0 rows)

  Tue Jan 23 15:18:52 2024 (every 1s)

   id | node | timestamp
  ----+------+-----------
  (0 rows)
  ```
- BR: 
  `psql bdrdb`

  `INSERT INTO ping(node, timestamp) select node_name, current_timestamp from bdr.local_node_summary; \watch 1`

  `CTRL-C`

- TR: `cat pgd-demo-app.sql`

  ```
  \pset footer off
  select node_name CONNECTED_TO from bdr.local_node_summary;
  select count(*) from ping;
  INSERT INTO ping(node, timestamp) select node_name, current_timestamp from bdr.local_node_summary;
  ```
  
  `cat testapp_east.sh`

  ```
  while true;
    do
      psql \
        -h pgd1-useast2,pgd2-useast2,pgd1-uswest2,pgd2-uswest2 \
        -U enterprisedb \
        -p 6432 \
        -d bdrdb \
        -f pgd-demo-app.sql;
      date;
    done
  ```

  `./testapp_east.sh`

  ```
  Tue Jan 23 15:25:31 UTC 2024
   connected_to
  --------------
   pgd1-useast2

   count
  -------
      52

  INSERT 0 1
  Tue Jan 23 15:25:31 UTC 2024
   connected_to
  --------------
   pgd1-useast2

   count
  -------
      53
  ```

- TL: `./testapp_west.sh`

  ```
              Tue Jan 23 15:27:01 2024 (every 1s)

     id    |     node     |            timestamp
  ---------+--------------+----------------------------------
   2000064 | pgd1-uswest2 | 23-JAN-24 15:27:01.659799 +00:00
   2000063 | pgd1-uswest2 | 23-JAN-24 15:27:01.458368 +00:00
       303 | pgd1-useast2 | 23-JAN-24 15:27:01.426207 +00:00
   2000062 | pgd1-uswest2 | 23-JAN-24 15:27:01.264456 +00:00
   2000061 | pgd1-uswest2 | 23-JAN-24 15:27:01.079349 +00:00
       302 | pgd1-useast2 | 23-JAN-24 15:27:00.975171 +00:00
   2000060 | pgd1-uswest2 | 23-JAN-24 15:27:00.871546 +00:00
       301 | pgd1-useast2 | 23-JAN-24 15:27:00.720818 +00:00
   2000059 | pgd1-uswest2 | 23-JAN-24 15:27:00.6867 +00:00
   2000058 | pgd1-uswest2 | 23-JAN-24 15:27:00.492987 +00:00
  (10 rows)
  ```

- Open new terminal window.
  
  `vagrant ssh`

  `cd sro-pgdcluster-mr`

  `ssh -F ssh_config barman-useast2`

  `sudo su - enterprisedb`

  `cd monitoring`

  `export LC_ALL=en_US.UTF-8`

  `watch -n 1 --color ./monitoring.sh`

  ```
  ********************************************************************
  *** Sergio PGD monitoring tool (Tue 23 Jan 2024 03:33:33 PM UTC) ***
  ********************************************************************

             ┌─────────────────────────────────────┐                ┌─────────────────────────────────────┐
             │ Location A: us-west-2               │                │ Location B: us-east-2               │
             │             Oregon                  │                │             Ohio                    │
             │ ┌─ AZ1 ─────────────────────────┐   │                │ ┌- AZ1 ─────────────────────────┐   │
             │ │ PGD A1 -> pgd1-uswest2        │   │                │ │ PGD B2 -> pgd1-useast2        │   │
             │ │ PGD-Proxy                     │   │                │ │ PGD-Proxy                     │   │
             │ │ Write leader: pgd1-uswest2    │   │                │ │ Write leader: pgd1-useast2    │   │
             │ └───────────────────────────────┘   │                │ └───────────────────────────────┘   │
             │ ┌─ AZ2 ─────────────────────────┐   │◄──────────────►│ ┌─ AZ2 ─────────────────────────┐   │
             │ │ PGD A2 -> pgd2-uswest2        │   │                │ │ PGD B2 -> pgd2-useast2        │   │
             │ │ PGD-Proxy                     │   │                │ │ PGD-Proxy                     │   │
             │ │ Write leader: pgd1-uswest2    │   │                │ │ Write leader: pgd1-useast2    │   │
             │ └───────────────────────────────┘   │                │ └───────────────────────────────┘   │
             │ ┌─ AZ3 ─────────────────────────┐   │                │ ┌- AZ3 ─────────────────────────┐   │
             │ │ PGD A3                        │   │                │ │ PGD B3                        │   │
             │ │ barman-uswest2                │   │                │ │ barman-useast2                │   │
             │ └───────────────────────────────┘   │                │ └───────────────────────────────┘   │
             └─────────────────────────────────────┘                └─────────────────────────────────────┘
                               ▲                                                      ▲
                               │                                                      │
                               │        ┌─────────────────────────────────────┐       │
                               │        │ Location C: us-east-1               │       │
                               │        │             Virginia                │       │
                               └───────►│ ┌─ AZ1 ─────────────────────────┐   │◄──────┘
                                        │ │ witness-useast1               │   │
                                        │ └───────────────────────────────┘   │
                                        └─────────────────────────────────────┘


  **********************
  *** Monitoring Lag ***
  **********************

     target_name   | client_addr | sent_lsn  | replay_lsn |   replay_lag    | replay_lag_bytes | replay_lag_size
  -----------------+-------------+-----------+------------+-----------------+------------------+-----------------
   pgd2-useast2    | 10.33.2.118 | 0/C6CCBA0 | 0/C6CCBA0  | 00:00:00        |                0 | 0 bytes
   barman-useast2  | 10.33.3.74  | 0/C6CCBA0 | 0/C6CCBA0  | 00:00:00        |                0 | 0 bytes
   witness-useast1 | 10.35.1.115 | 0/C6CCBA0 | 0/C6CCBA0  | 00:00:00.011445 |                0 | 0 bytes
   barman-uswest2  | 10.34.3.96  | 0/C6CCBA0 | 0/C6CCBA0  | 00:00:00.048931 |                0 | 0 bytes
   pgd2-uswest2    | 10.34.2.110 | 0/C6CCBA0 | 0/C6CCBA0  | 00:00:00.049965 |                0 | 0 bytes
   pgd1-uswest2    | 10.34.1.89  | 0/C6CCBA0 | 0/C6CCBA0  | 00:00:00.050088 |                0 | 0 bytes
                   |             | 0/C17D870 | 0/C17D870  | 02:37:10.898401 |          5567280 | 5437 kB
  ```

- BR: `./switchover_to_pgd2-useast2.sh`

  ```
                Tue Jan 23 15:44:56 2024 (every 1s)

     id    |     node     |            timestamp
  ---------+--------------+----------------------------------
   4000005 | pgd2-useast2 | 23-JAN-24 15:44:56.856235 +00:00
   2004712 | pgd1-uswest2 | 23-JAN-24 15:44:56.751754 +00:00
   4000004 | pgd2-useast2 | 23-JAN-24 15:44:56.56861 +00:00
   2004711 | pgd1-uswest2 | 23-JAN-24 15:44:56.564589 +00:00
   2004710 | pgd1-uswest2 | 23-JAN-24 15:44:56.35357 +00:00
   4000003 | pgd2-useast2 | 23-JAN-24 15:44:56.184204 +00:00
   2004709 | pgd1-uswest2 | 23-JAN-24 15:44:56.148546 +00:00
   2004708 | pgd1-uswest2 | 23-JAN-24 15:44:55.957864 +00:00
   2004707 | pgd1-uswest2 | 23-JAN-24 15:44:55.778521 +00:00
   2004706 | pgd1-uswest2 | 23-JAN-24 15:44:55.586782 +00:00
  (10 rows)
  ```

  Show monitoring screen.

- BR: 
  
  `psql bdrdb -c "vacuum full analyze;"`
  
  `./switchover_to_pgd1-useast2.sh`

Show data. Show monitor.

### 02-Failover

- BR: 
  `CTRL-D` (become admin)

  `sudo su` (become root)

  `cd /var/lib/edb-as/scripts/02-failover`

  `./stop_postgres_node.sh`

  ```
    Tue Jan 23 15:57:15 UTC 2024
   connected_to
  --------------
   pgd1-useast2

   count
  -------
   12226

  INSERT 0 1
  Tue Jan 23 15:57:16 UTC 2024
  psql: error: connection to server at "pgd1-useast2" (10.33.1.93), port 6432 failed: SSL connection has been closed unexpectedly
  Tue Jan 23 15:57:16 UTC 2024
   connected_to
  --------------
   pgd2-useast2

   count
  -------
   12230
  ```

Show monitor. Show data.

- BL: `./start_postgres_node.sh`

### 03-Conflics

Stop all panes.

#### 3a INSERT-INSERT
- BL:
  `psql bdrdb`

  `create table names(name text, number integer primary key);`

- BR:
  `psql bdrdb`

  `\dt`

  ```
               List of relations
   Schema | Name  | Type  |    Owner
  --------+-------+-------+--------------
   public | names | table | enterprisedb
   public | ping  | table | enterprisedb
  (2 rows)
  ```

  `select * from names; \watch`

- BL: `select * from bdr.conflict_history_summary; \watch`

- TL:
  `\! clear`

  `begin; insert into names(name, number) values('Ton',1);`

- TR: 
  `\! clear`
  `begin; insert into names(name, number) values('James',1);`

### 04-Upgrades

### 06-Selective Replication

### Transparent Data Encryption
