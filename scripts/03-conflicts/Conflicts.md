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
