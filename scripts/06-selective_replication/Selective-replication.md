### 06-Selective Replication


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
