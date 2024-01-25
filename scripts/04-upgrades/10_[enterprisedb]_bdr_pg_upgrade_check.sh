#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

cd

#Patch to avoid error:
#command: "/usr/lib/edb-as/16/bin/pg_dump" --host /var/run/edb-as --port 5444 --username enterprisedb --schema-only --quote-all-identifiers --binary-upgrade --format=custom  --file="/opt/postgres/data/pg_upgrade_output.d/20240124T155559.121/dump/pg_upgrade_dump_16946.custom" 'dbname=bdrdb' >> "/opt/postgres/data/pg_upgrade_output.d/20240124T155559.121/log/pg_upgrade_dump_16946.log" 2>&1
#pg_dump: error: query to get data of sequence "ping_id_seq" returned 3 rows (expected 1)
psql -h pgd1-useast2,pgd2-useast2,pgd1-uswest2,pgd2-uswestt2 -p 6432 bdrdb -c "
drop sequence if exists ping_id_seq cascade; commit;"
#End patch

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
  --check \
  --copy-by-block
