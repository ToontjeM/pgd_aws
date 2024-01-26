#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

sudo systemctl start postgres
sudo systemctl status postgres
