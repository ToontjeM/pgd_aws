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

- BL: 
  `\x`

  `select * from bdr.conflict_history_summary; \watch`

- TL:
  `\! clear`

  `begin; insert into names(name, number) values('Ton',1);`

- TR: 
  `\! clear`
  `begin; insert into names(name, number) values('James',1);`

- TL: `commit;`
- TR: `commit;`
- BR: `select * from names;`

``` 
-[ RECORD 1 ]-
name   | James
number | 1
```

- BL:
```
-[ RECORD 1 ]-----------+---------------------------------
nspname                 | public
relname                 | names
origin_node_id          | 4
remote_commit_lsn       | 0/9109AE0
remote_change_nr        | 2
local_time              | 24-JAN-24 13:15:40.035736 +00:00
local_tuple_commit_time | 24-JAN-24 13:15:28.657639 +00:00
remote_commit_time      | 24-JAN-24 13:15:40.008453 +00:00
conflict_type           | insert_exists
conflict_resolution     | apply_remote
```

#### 3b UPDATE-UPDATE

- TL:
  `\! clear`

  `begin; update names set number=2 where number=1`

- TR:
  `\! clear`

  `begin; update names set number=3 where number=1`

- TL: `commit;`
- TR: `commit;`
- BR: `select * from names;`

  ```
  -[ RECORD 1 ]-
   name  | number
  -------+--------
   James |      3
   James |      2
  (2 rows)

  ```

- BL: 
  ``` 
  -[ RECORD 2 ]-----------+---------------------------------
  nspname                 | public
  relname                 | names
  origin_node_id          | 4
  remote_commit_lsn       | 0/9190F90
  remote_change_nr        | 2
  local_time              | 24-JAN-24 13:41:06.934217 +00:00
  local_tuple_commit_time |
  remote_commit_time      | 24-JAN-24 13:40:12.759348 +00:00
  conflict_type           | update_missing
  conflict_resolution     | apply_remote
  ```

#### UPDATE-DELETE

- TL:
  `\! clear`

  `begin; delete from names where number=1;`

- TR:
  `\! clear`

  `begin; update names set name="Pete" where number=1;`

- TL: `commit;`
- TR: `commit;`
- BR: `select * from names;`

```
-[ RECORD 3 ]-----------+---------------------------------
nspname                 | public
relname                 | names
origin_node_id          | 4
remote_commit_lsn       | 0/9399090
remote_change_nr        | 2
local_time              | 24-JAN-24 15:10:26.805978 +00:00
local_tuple_commit_time |
remote_commit_time      | 24-JAN-24 15:10:26.780809 +00:00
conflict_type           | update_missing
conflict_resolution     | apply_remote
```

### 04-Upgrades

Open two panes, both logged in to pgd1-useast2.
- Left panel (L): 
  `sudo -i`
  `cd /var/lib/edb-as/scripts/04-upgrades/`

- Right panel (R):
  `sudo su - enterprisedb`
  `cd scripts/04-upgrades`

- R: 
  - Show current PGD version using `./01_[enterprisedb]_show_version.sh`.

    ```
      Node            BDR Version Postgres Version
    ----            ----------- ----------------
    barman-useast2  5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    barman-uswest2  5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    pgd1-useast2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    pgd1-uswest2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    pgd2-useast2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    pgd2-uswest2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    witness-useast1 5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    ```
  - Switch to PGD2 as write leader using `./02_[enterprisedb]_switchover.sh`. Show Monitoring if needed.
    ```
    switchover is complete
    ```

- L: 
  - Stop Postgres using `./03_[root]_stop_postgres.sh`.

  - Install EPAS16 using `./04_[root]_install_edb_pgd5.sh`
    ```
    Success. You can now start the database server using:

    /usr/lib/edb-as/16/bin/pg_ctl -D /var/lib/edb-as/16/main -l logfile start

    Ver Cluster Port Status Owner        Data directory          Log file
    16  main    5445 down   enterprisedb /var/lib/edb-as/16/main /var/log/edb-as/edb-as-16-main.log
    Setting up edb-bdr5-epas16 (4:5.3.0-11.buster) ...
    Processing triggers for edb-as-common (196) ...
    Building EPAS dictionaries from installed myspell/hunspell packages...
    Removing obsolete dictionary files:
    ```

  - Create new data directories using `./05_[root]_create_new_data_directories.sh`
    ```
    drwx------ 21 enterprisedb enterprisedb  4096 Jan 24 15:42 data
    drwxr-xr-x  2 enterprisedb enterprisedb  4096 Jan 24 15:45 datanew
    drwx------  2 root         root         16384 Jan 23 12:43 lost+found
    ```

- R:
  - Create new DB using `./06_[enterprisedb]_initdb_epas16.sh`
    ```
    Success. You can now start the database server using:

    /usr/lib/edb-as/16/bin/pg_ctl -D /opt/postgres/datanew -l logfile start
    ```

  - Migrate Postgres configuration to new version using `./07_[enterprisedb]_copy_config.sh`

- L:
  - Move data to new version using `./08_[root]rename_pgdata.sh`

- R:
  - Make sure both versions of Postgres are stopped using `./09_[enterprisedb]_stop_instances.sh`

  - Check of both instances are ready for upgrading using `./10_[enterprisedb]_bdr_pg_upgrade_check.sh`

    ```
      Performing BDR Postgres Checks
      ------------------------------
      Collecting pre-upgrade new cluster control data             ok
      Checking new cluster state is shutdown                      ok
      Checking BDR versions                                       ok

      Passed all bdr_pg_upgrade checks, now calling pg_upgrade

      Performing Consistency Checks
      -----------------------------
      Checking cluster versions                                     ok
      Checking database user is the install user                    ok
      Checking database connection settings                         ok
      Checking for prepared transactions                            ok
      Checking for system-defined composite types in user tables    ok
      Checking for reg* data types in user tables                   ok
      Checking for contrib/isn with bigint-passing mismatch         ok
      Checking for incompatible "aclitem" data type in user tables  ok
      Checking for presence of required libraries                   ok
      Checking database user is the install user                    ok
      Checking for prepared transactions                            ok
      Checking for new cluster tablespace directories               ok

      Clusters are compatible*
    ```

  - Perform the actuall update using `./11_[enterprisedb]_bdr_pg_upgrade.sh`
    ```
    pg_upgrade complete, performing BDR post-upgrade steps
    ------------------------------------------------------
    Collecting old cluster control data                         ok
    Collecting new cluster control data                         ok
    Checking LSN of new cluster                                 ok
    Starting new cluster with BDR disabled                      ok
    Connecting to new cluster                                   ok
    Creating replication origin (bdr_bdrdb_pgdcluster_barman... ok
    Advancing replication origin (bdr_bdrdb_pgdcluster_barma... ok
    Creating replication origin (bdr_bdrdb_pgdcluster_pgd2_u... ok
    Advancing replication origin (bdr_bdrdb_pgdcluster_pgd2_... ok
    Creating replication origin (bdr_bdrdb_pgdcluster_barman... ok
    Advancing replication origin (bdr_bdrdb_pgdcluster_barma... ok
    Creating replication origin (bdr_bdrdb_pgdcluster_pgd1_u... ok
    Advancing replication origin (bdr_bdrdb_pgdcluster_pgd1_... ok
    Creating replication origin (bdr_bdrdb_pgdcluster_witnes... ok
    Advancing replication origin (bdr_bdrdb_pgdcluster_witne... ok
    Creating replication origin (bdr_bdrdb_pgdcluster_pgd2_u... ok
    Advancing replication origin (bdr_bdrdb_pgdcluster_pgd2_... ok
    Creating replication slot (bdr_bdrdb_pgdcluster_witness_... ok
    Creating replication slot (bdr_bdrdb_pgdcluster)            ok
    Creating replication slot (bdr_bdrdb_pgdcluster_pgd2_use... ok
    Creating replication slot (bdr_bdrdb_pgdcluster_pgd2_usw... ok
    Creating replication slot (bdr_bdrdb_pgdcluster_barman_u... ok
    Creating replication slot (bdr_bdrdb_pgdcluster_pgd1_usw... ok
    Creating replication slot (bdr_bdrdb_pgdcluster_barman_u... ok
    Stopping new cluster                                        ok
    ```

  - L: 
    - Update postgres systemd service using `./12_[root]_amend_service.sh`
    - Start postgres using `./13_[root]_start_postgres.sh`
    ```
    ● postgres.service - Postgres 16 (TPA)
    Loaded: loaded (/etc/systemd/system/postgres.service; enabled; vendor preset: enabled)
    Active: active (running) since Thu 2024-01-25 10:53:22 UTC; 21ms ago
    Process: 25518 ExecStartPost=/bin/bash -c echo 0xff > /proc/$MAINPID/coredump_filter (code=exited, status=0/SUCCESS)
    Main PID: 25517 (edb-postgres)
     Tasks: 1 (limit: 2330)
    Memory: 2.2M
    CGroup: /system.slice/postgres.service
            └─25517 /usr/lib/edb-as/16/bin/edb-postgres -D /opt/postgres/data -c config_file=/opt/postgres/data/postgresql.conf
    ```

  - R:
    - Check status of the new cluster using `./14_[enterprisedb]_check.sh`
    ```
    Node            Node ID    Group              Type    Current State Target State Status Seq ID
    ----            -------    -----              ----    ------------- ------------ ------ ------
    witness-useast1 3682350484 us_east_1_subgroup witness ACTIVE        ACTIVE       Up     5
    pgd1-useast2    2853216890 us_east_2_subgroup data    ACTIVE        ACTIVE       Up     4
    pgd2-useast2    3103007853 us_east_2_subgroup data    ACTIVE        ACTIVE       Up     3
    barman-useast2  1617690369 us_east_2_subgroup witness ACTIVE        ACTIVE       Up     6
    pgd1-uswest2    1906171131 us_west_2_subgroup data    ACTIVE        ACTIVE       Up     1
    pgd2-uswest2    3803119516 us_west_2_subgroup data    ACTIVE        ACTIVE       Up     7
    barman-uswest2  3478913282 us_west_2_subgroup witness ACTIVE        ACTIVE       Up     2
    Node            BDR Version Postgres Version
    ----            ----------- ----------------
    barman-useast2  5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    barman-uswest2  5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    pgd1-useast2    5.3.0       16.1.0 (Debian 16.1.0-1.buster)
    pgd1-uswest2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    pgd2-useast2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    pgd2-uswest2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    witness-useast1 5.3.0       15.5.0 (Debian 15.5.0-1.buster)
    Instance Group              Node            Raft State    Raft Term Commit Index Nodes Voting Nodes Protocol Version
    -------- -----              ----            ----------    --------- ------------ ----- ------------ ----------------
    1        pgdcluster         barman-uswest2  RAFT_LEADER   2         18286        7     7            5002
    1        pgdcluster         barman-useast2  RAFT_FOLLOWER 2         18286        7     7            5002
    1        pgdcluster         pgd1-useast2    RAFT_FOLLOWER 2         18286        7     7            5002
    1        pgdcluster         pgd1-uswest2    RAFT_FOLLOWER 2         18286        7     7            5002
    1        pgdcluster         pgd2-useast2    RAFT_FOLLOWER 2         18286        7     7            5002
    1        pgdcluster         pgd2-uswest2    RAFT_FOLLOWER 2         18286        7     7            5002
    1        pgdcluster         witness-useast1 RAFT_FOLLOWER 2         18286        7     7            5002
    2        us_east_2_subgroup barman-useast2  RAFT_LEADER   1         19           3     3            0
    2        us_east_2_subgroup pgd1-useast2    RAFT_FOLLOWER 1         19           3     3            0
    2        us_east_2_subgroup pgd2-useast2    RAFT_FOLLOWER 1         19           3     3            0
    3        us_west_2_subgroup pgd1-uswest2    RAFT_LEADER   2         3            3     3            0
    3        us_west_2_subgroup barman-uswest2  RAFT_FOLLOWER 2         3            3     3            0
    3        us_west_2_subgroup pgd2-uswest2    RAFT_FOLLOWER 2         3            3     3            0
    Node            barman-useast2 barman-uswest2 pgd1-useast2 pgd1-uswest2 pgd2-useast2 pgd2-uswest2 witness-useast1
    ----            -------------- -------------- ------------ ------------ ------------ ------------ ---------------
    barman-useast2  *              *              *            *            *            *            *
    barman-uswest2  *              *              *            *            *            *            *
    pgd1-useast2    *              *              *            *            *            *            *
    pgd1-uswest2    *              *              *            *            *            *            *
    pgd2-useast2    *              *              *            *            *            *            *
    pgd2-uswest2    *              *              *            *            *            *            *
    witness-useast1 *              *              *            *            *            *            *
    ```

  - Upgrade extensions using `./15_[enterprisedb]_upgrade_extensions.sh`
    ```
    psql.bin (16.1.0 (Debian 16.1.0-1.buster), server 16.1.0 (Debian 16.1.0-1.buster))
    You are now connected to database "template1" as user "enterprisedb".
    ALTER EXTENSION
    psql.bin (16.1.0 (Debian 16.1.0-1.buster), server 16.1.0 (Debian 16.1.0-1.buster))
    You are now connected to database "postgres" as user "enterprisedb".
    ALTER EXTENSION
    psql.bin (16.1.0 (Debian 16.1.0-1.buster), server 16.1.0 (Debian 16.1.0-1.buster))
    You are now connected to database "bdrdb" as user "enterprisedb".
    ALTER EXTENSION
    ```

  - Clean up (vacuum) the new cluster using `./16_[enterprisedb]_vacuumdb.sh`
    ```
    NOTICE:  skipped replication for captured DDL command "ANALYZE" in replication sets (pgdcluster): this statement type is not replicated by BDR
    NOTICE:  skipped replication for captured DDL command "ANALYZE" in replication sets (pgdcluster): this statement type is not replicated by BDR
    vacuumdb: processing database "edb": Generating default (full) optimizer statistics
    vacuumdb: processing database "postgres": Generating default (full) optimizer statistics
    vacuumdb: processing database "template1": Generating default (full) optimizer statistics
    ```

  - Allow access to the database using `./17_[enterprisedb]_reenable_access.sh`
    ```
    UPDATE 1
      datname  | datconnlimit
    -----------+--------------
     template0 |           -1
     template1 |           -1
     postgres  |           -1
     edb       |           -1
     bdrdb     |           -1
    (5 rows)
    ```

  - Perform the final switch-over to the new version using `./18_[enterprisedb]_switchover.sh`
    ```
    switchover is complete
    ```

- L:
  - And finally remove the old version using `./20_[root]_remove_old_epas.sh`

Final situation:
```
Node            BDR Version Postgres Version
----            ----------- ----------------
barman-useast2  5.3.0       15.5.0 (Debian 15.5.0-1.buster)
barman-uswest2  5.3.0       15.5.0 (Debian 15.5.0-1.buster)
pgd1-useast2    5.3.0       16.1.0 (Debian 16.1.0-1.buster) <--
pgd1-uswest2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
pgd2-useast2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
pgd2-uswest2    5.3.0       15.5.0 (Debian 15.5.0-1.buster)
witness-useast1 5.3.0       15.5.0 (Debian 15.5.0-1.buster)
```

### 06-Selective Replication

- L:
  - Create a new set of tables using `./01_create_tables.sh`
  - Show tables and replicationsets using `./02_show _tables_in_replicationsets.sh`

    ```
      node_group_name   |   default_repset   | parent_group_name
    --------------------+--------------------+-------------------
     us_east_1_subgroup | us_east_1_subgroup | pgdcluster
     pgdcluster         | pgdcluster         |
     us_east_2_subgroup | us_east_2_subgroup | pgdcluster
     us_west_2_subgroup | us_west_2_subgroup | pgdcluster
    (4 rows)

     relname  |  set_name
    ----------+------------
     attendee | pgdcluster
     names    | pgdcluster
     opinion  | pgdcluster
     ping     | pgdcluster
     work     | pgdcluster
    (5 rows)
    ```
  - Add table `opinion` to EAST and WEST subgroup, remove `opinion` from parentand add some data to `work` and `attendee` using `./03_modify_replicationsets.sh`
    ```
     relname  |  set_name
    ----------+------------
     attendee | pgdcluster
     names    | pgdcluster
     opinion  |
     ping     | pgdcluster
     work     | pgdcluster
    (5 rows)
    ```
  - Add different data to the table `opinion` for East and West using `04_add_data.sh`

  - Show data in East and West using `05_show_data.sh`

  
### Transparent Data Encryption

The TDE demo needs to be performed on a separate environment. Instructions on how to run the demo can be found [here](./scripts/07-tde/tde.README.md).