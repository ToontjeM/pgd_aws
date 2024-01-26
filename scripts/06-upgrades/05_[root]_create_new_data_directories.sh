#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

sudo mkdir /opt/postgres/datanew
sudo chown enterprisedb.enterprisedb /opt/postgres/datanew
ls -l /opt/postgres

