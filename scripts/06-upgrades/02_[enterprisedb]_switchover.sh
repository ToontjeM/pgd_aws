#!/bin/bash

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

pgd switchover --group-name us_east_2_subgroup --node-name pgd2-useast2

