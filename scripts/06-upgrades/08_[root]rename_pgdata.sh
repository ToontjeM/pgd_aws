#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

sudo mv /opt/postgres/data /opt/postgres/dataold
sudo mv /opt/postgres/datanew /opt/postgres/data

