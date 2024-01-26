#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

cd

psql bdrdb -f update_extensions.sql
