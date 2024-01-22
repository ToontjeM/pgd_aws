#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Configure and provision with TPA the new architecture PGD-Always-ON                                     #
# Description: Configure and provision with TPA the new architecture PGD-Always-ON                                     #
########################################################################################################################

. ./config.sh
. /vagrant/repo.sh

#export EDB_SUBSCRIPTION_TOKEN=$repo_credentials

rm -Rf ~/sro-pgdcluster-mr

tpaexec configure ~/sro-pgdcluster-mr  \
        --architecture PGD-Always-ON  \
        --platform aws  \
        --postgresql \
        --postgres-version 15 \
        --pgd-proxy-routing local

yes | cp -f /vagrant/yml/MRLR4DN-config.yml ~/sro-pgdcluster-mr/config.yml

tpaexec provision ~/sro-pgdcluster-mr

