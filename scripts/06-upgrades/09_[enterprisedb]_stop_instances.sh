#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

#/usr/edb/as15/bin/pg_ctl -D /opt/postgres/dataold stop
#/usr/edb/as16/bin/pg_ctl -D /opt/postgres/data stop

/usr/lib/edb-as/15/bin/pg_ctl -D /opt/postgres/dataold stop
/usr/lib/edb-as/16/bin/pg_ctl -D /opt/postgres/data stop
