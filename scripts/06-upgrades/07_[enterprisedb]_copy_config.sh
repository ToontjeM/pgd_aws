#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi
cp /opt/postgres/data/postgresql.conf /opt/postgres/datanew/
cp /opt/postgres/data/postgresql.auto.conf /opt/postgres/datanew/
cp /opt/postgres/data/pg_hba.conf /opt/postgres/datanew/
cp -r /opt/postgres/data/conf.d/ /opt/postgres/datanew/
