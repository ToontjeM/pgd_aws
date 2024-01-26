#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi
sudo apt-get -y install edb-bdr5-epas16 edb-bdr-utilities

