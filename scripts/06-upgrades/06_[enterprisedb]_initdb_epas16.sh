#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

#rhel/rocky
#/usr/edb/as16/bin/initdb  \

export PGDATAKEYWRAPCMD='-'
export PGDATAKEYUNWRAPCMD='-'

#debian
/usr/lib/edb-as/16/bin/initdb \
  -D /opt/postgres/datanew \
  -E UTF8 \
  --lc-collate=C.UTF-8 \
  --lc-ctype=C.UTF-8 \
  --data-checksums \
  --data-encryption
