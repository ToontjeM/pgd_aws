#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

pgd show-nodes
pgd show-version
pgd show-raft
pgd show-replslots

