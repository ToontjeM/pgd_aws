#!/bin/bash

psql -h pgd1-useast2,pgd2-useast2,pgd1-uswest2,pgd2-uswestt2 -p 6432 bdrdb -c "
drop table if exists test_conflict;
create table test_conflict(
  id integer primary key ,
  value_1 text);
"
