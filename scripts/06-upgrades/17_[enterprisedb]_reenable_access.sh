#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

psql bdrdb -c "
select datname, datconnlimit from pg_database;
update pg_database set datconnlimit = -1 where datname = 'bdrdb';
select datname, datconnlimit from pg_database;
"

