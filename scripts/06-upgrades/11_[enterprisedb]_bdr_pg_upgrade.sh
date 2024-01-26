#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

cd

export PGDATAKEYWRAPCMD='-'
export PGDATAKEYUNWRAPCMD='-'

/usr/bin/bdr_pg_upgrade \
  --old-bindir /usr/lib/edb-as/15/bin/ \
  --new-bindir /usr/lib/edb-as/16/bin/ \
  --old-datadir /opt/postgres/dataold/ \
  --new-datadir /opt/postgres/data/ \
  --database bdrdb \
  --old-port 5444 \
  --new-port 5444 \
  --socketdir /var/run/edb-as \
  --copy-by-block
