#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Copy scripts                                                                                            #
# Description: Copy demo scripts and monitoring tool to each AWS machine                                               #
########################################################################################################################

. ./config.sh

# Password is necessary for monitoring tool
echo "Export password to file"
tpaexec show-password ~/sro-pgdcluster-mr enterprisedb > /tmp/password.txt
head -n 1 /tmp/password.txt > password.txt

cd ~/sro-pgdcluster-mr

arr=("pgd1-useast2" "pgd2-useast2" "pgd1-uswest2" "pgd2-uswest2" "witness-useast1" "barman-useast2" "barman-uswest2")
i=0
len=${#arr[@]}

while [ $i -lt $len ];
do
  machine=${arr[$i]}
  echo "************************************"
  echo "Copy files to $machine"
  echo "************************************"
  echo ""
  # echo "scp -r -F ~/sro-pgdcluster-mr/ssh_config /vagrant/* admin@$machine:/tmp/."
  # echo ""
  # scp -r -F ~/sro-pgdcluster-mr/ssh_config /vagrant/* admin@$machine:/tmp/.
  # # Delete old version
  # ssh -F ssh_config  $machine "sudo rm -Rf /var/lib/edb-as/scripts"
  # ssh -F ssh_config  $machine "sudo rm -Rf /var/lib/edb-as/monitoring"
  # ssh -F ssh_config  $machine "sudo rm -Rf /var/lib/edb-as/*.sh"
  # # Copy from /tmp to .
  # ssh -F ssh_config  $machine "sudo cp -r /tmp/. /var/lib/edb-as/."
  # ssh -F ssh_config  $machine "sudo cp /tmp/password.txt /var/lib/edb-as/."
  # ssh -F ssh_config  $machine "sudo mkdir /var/lib/edb-as/scripts"
  # ssh -F ssh_config  $machine "sudo cp -r /tmp/scripts/* /var/lib/edb-as/scripts"
  # let i++

  ssh -F ssh_config  $machine "rm -rf /tmp/scripts"
  ssh -F ssh_config  $machine "rm -rf /tmp/monitoring"
  ssh -F ssh_config  $machine "mkdir /tmp/scripts"
  ssh -F ssh_config  $machine "mkdir /tmp/monitoring"
  scp -r -F ~/sro-pgdcluster-mr/ssh_config /vagrant/monitoring/*.* admin@$machine:/tmp/monitoring
  scp -r -F ~/sro-pgdcluster-mr/ssh_config /vagrant/scripts/* admin@$machine:/tmp/scripts
  scp -r -F ~/sro-pgdcluster-mr/ssh_config /vagrant/password.txt admin@$machine:/tmp/password.txt
  ssh -F ssh_config  $machine "sudo mkdir /var/lib/edb-as/monitoring"
  ssh -F ssh_config  $machine "sudo mkdir /var/lib/edb-as/scripts"
  ssh -F ssh_config  $machine "sudo cp -r /tmp/monitoring/* /var/lib/edb-as/monitoring"
  ssh -F ssh_config  $machine "sudo cp -r /tmp/scripts/* /var/lib/edb-as/scripts"
  ssh -F ssh_config  $machine "sudo cp -r /tmp/password.txt /var/lib/edb-as/password.txt"
  ssh -F ssh_config  $machine "sudo rm /tmp/nodes.txt"
  ssh -F ssh_config  $machine "sudo rm /tmp/groups.txt"
  ssh -F ssh_config  $machine "sudo rm /tmp/nodes_tmp.txt"
  ssh -F ssh_config  $machine "sudo rm /tmp/groups_tmp.txt"

  let i++

done

cd -
echo ""
echo "Warning: Execute this command in each VM with enterprisedb user"
echo "cd"
echo "cp -r /tmp/* ."
