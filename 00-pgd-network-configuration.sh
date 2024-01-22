#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Network configuration                                                                                   #
# Description: This script create and provision with TPA the necessary network to operate with a PGD cluster           #
# PGD infos:                                                                                                           #
#   Virginia: us-east-1 (10.35.0.0/16)                                                                                 #
#   Ohio:     us-east-2 (10.33.0.0/16)                                                                                 #
#   Oregon:   us-west-2 (10.34.0.0/16)                                                                                 #
########################################################################################################################

. ./config.sh

cd
git config --global user.email "ton.machielsen@enterprisedb.com"
git config --global user.name "Ton Machielsen"

rm -rf ~/sro-pgdnetwork

#tpaexec setup
#tpaexec setup --use-2q-ansible
#
## Test
#tpaexec selftest

tpaexec configure ~/sro-pgdnetwork  --architecture PGD-Always-ON \
                                    --platform aws  \
                                    --postgresql \
                                    --postgres-version 15 \
                                    --pgd-proxy-routing local

yes | cp -f /vagrant/yml/PGDNetwork.yml ~/sro-pgdnetwork/config.yml

mkdir ~/.aws
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
aws_session_token=$AWS_SESSION_TOKEN
EOF

tpaexec provision ~/sro-pgdnetwork

# Deprovision
#tpaexec deprovision ~/sro-pgdnetwork
tpaexec deprovision ~/sro-pgdnetwork --tags ec2