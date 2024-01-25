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