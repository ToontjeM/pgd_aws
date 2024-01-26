#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi
sudo sed -i -e 's/15/16/g' /etc/systemd/system/postgres.service
sudo systemctl daemon-reload
