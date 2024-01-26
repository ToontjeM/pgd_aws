

# Drop cluster
```
stop
mv ~/as15/data ~/as15/data.old
rm -rf ~/as15/data.old
```
# Create non encrypted cluster
```
/usr/edb/as15/bin/initdb -D /var/lib/edb/as15/data 
```

# Start cluster
```
pg_ctl start
```

# Create TDE cluster
```
export PGDATAKEYWRAPCMD='openssl enc -e -aes256 -pass pass:ok -out %p'
export PGDATAKEYUNWRAPCMD='openssl enc -d -aes256 -pass pass:ok -in %p'

/usr/edb/as15/bin/initdb --data-encryption -D /var/lib/edb/as15/data 
```

# Create table test
```
--drop table test;
--create table test (id int, description varchar(100));
--insert into test values (1, 'abc');

--create table users (userid int, password varchar(100));
--insert into users values (1, 'Thisismypassword01#');

drop table users;
create table users (userid int, user_name varchar2(10), password varchar(100));
insert into users values (1, 'sergio', 'ThisismySKOpassword####');


-- Flush dirty pages
checkpoint;

select pg_relation_filepath('users');

-- Check Encryption activated
select data_encryption_version from pg_control_init;

 data_encryption_version
-------------------------
                       1
(1 row)
```

# Show file content
```
ll $PGDATA/base/5/16384
cat $PGDATA/base/5/16384
hexdump -C $PGDATA/base/5/16384
hexdump -C $PGDATA/base/5/16384 | grep sergio

cd $PGDATA/base/5
ll 16384
hexdump -C 16384 | grep abc
enterprisedb@postgresedb2:~/as15/data/base/5

hexdump -C 16384
00000000  00 00 00 00 f8 aa 06 03  00 00 00 00 1c 00 d0 1f  |................|
00000010  00 20 04 20 00 00 00 00  d0 9f 60 00 00 00 00 00  |. . ......`.....|
00000020  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
00001fd0  39 03 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |9...............|
00001fe0  01 00 02 00 02 08 18 00  01 00 00 00 29 54 68 69  |............)Thi|
00001ff0  73 69 73 6d 79 70 61 73  73 77 6f 72 64 30 31 23  |sismypassword01#|
00002000

hexdump -C 16384 | tail -5
00001fc0  ef 1b 96 f9 c8 44 a0 62  33 f3 64 1c cb d7 a5 5e  |.....D.b3.d....^|
00001fd0  4e 95 e0 f5 48 b3 3c 8a  1d 4d 24 ba 09 16 bc 73  |N...H.<..M$....s|
00001fe0  13 f8 f3 4e cf 3e cf 29  3b 25 28 f2 f1 b7 23 a1  |...N.>.);%(...#.|
00001ff0  2f f7 82 b5 96 b0 df 79  20 ae c8 e0 72 52 b4 00  |/......y ...rR..|
00002000
```

# pg_encryption directory
```
enterprisedb@postgresedb2:~/as15/data
>ll
total 72
drwx------. 6 enterprisedb enterprisedb    46 Mar 30 08:42 base
-rw-------. 1 enterprisedb enterprisedb    37 Mar 30 08:43 current_logfiles
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:43 dbms_pipe
drwx------. 2 enterprisedb enterprisedb  4096 Mar 30 08:43 global
drwx------. 2 enterprisedb enterprisedb    39 Mar 30 08:43 log
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_commit_ts
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_dynshmem
drwx------. 2 enterprisedb enterprisedb    21 Mar 30 08:42 pg_encryption
-rw-------. 1 enterprisedb enterprisedb  4789 Mar 30 08:42 pg_hba.conf
-rw-------. 1 enterprisedb enterprisedb  1636 Mar 30 08:42 pg_ident.conf
drwx------. 4 enterprisedb enterprisedb    68 Mar 30 08:42 pg_logical
drwx------. 4 enterprisedb enterprisedb    36 Mar 30 08:42 pg_multixact
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_notify
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_replslot
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_serial
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_snapshots
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:43 pg_stat
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_stat_tmp
drwx------. 2 enterprisedb enterprisedb    18 Mar 30 08:42 pg_subtrans
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_tblspc
drwx------. 2 enterprisedb enterprisedb     6 Mar 30 08:42 pg_twophase
-rw-------. 1 enterprisedb enterprisedb     3 Mar 30 08:42 PG_VERSION
drwx------. 3 enterprisedb enterprisedb   156 Mar 30 08:42 pg_wal
drwx------. 2 enterprisedb enterprisedb    18 Mar 30 08:42 pg_xact
-rw-------. 1 enterprisedb enterprisedb    88 Mar 30 08:42 postgresql.auto.conf
-rw-------. 1 enterprisedb enterprisedb 36121 Mar 30 08:42 postgresql.conf
-rw-------. 1 enterprisedb enterprisedb    31 Mar 30 08:43 postmaster.opts
-rw-------. 1 enterprisedb enterprisedb    81 Mar 30 08:43 postmaster.pid
enterprisedb@postgresedb2:~/as15/data
>cd pg_encryption/
enterprisedb@postgresedb2:~/as15/data/pg_encryption
>ll
total 4
-rw-------. 1 enterprisedb enterprisedb 112 Mar 30 08:42 key.bin
```




# *************
# Postgres Extended
# With postgres user
# Install
dnf -y install edb-postgresextended15-server edb-postgresextended15-contrib

# 
mv /var/lib/edb-pge/pge15/data /var/lib/edb-pge/pge15/data.old
rm -rf /var/lib/edb-pge/pge15/data/*

/usr/edb/pge15/bin/initdb -D /var/lib/edb-pge/pge15/data

# Start db
/usr/edb/pge15/bin/pg_ctl -D /var/lib/edb-pge/pge15/data -l logfile start

# Alias
alias status="/usr/edb/pge15/bin/pg_ctl status -D /var/lib/edb-pge/pge15/data"
alias stop="/usr/edb/pge15/bin/pg_ctl stop -D /var/lib/edb-pge/pge15/data"
alias start="/usr/edb/pge15/bin/pg_ctl start -D /var/lib/edb-pge/pge15/data"

# TDE
stop
mv /var/lib/edb-pge/pge15/data /var/lib/edb-pge/pge15/data.old

export PGDATAKEYWRAPCMD='openssl enc -e -aes256 -pass pass:ok -out %p'
export PGDATAKEYUNWRAPCMD='openssl enc -d -aes256 -pass pass:ok -in %p'

/usr/edb/pge15/bin/initdb --data-encryption -D /var/lib/edb-pge/pge15/data

# Create table
```

drop table users;
create table users (userid int, password varchar(100));
insert into users values (1, 'Thisismypassword01#');

-- Flush dirty pages
checkpoint;

select pg_relation_filepath('users');

-- Check Encryption activated
#select data_encryption_version from pg_control_init;
```
hexdump -C /var/lib/edb-pge/pge15/data/base/5/16384
