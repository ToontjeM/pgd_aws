#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

/usr/lib/edb-as/16/bin/vacuumdb --all --analyze-in-stages

