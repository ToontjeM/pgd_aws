#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Deploy PGD Multiregion cluster in AWS                                                                   #
# Description: PGD deployment in 3 regions                                                                             #
#           ┌─────────────────────────────────────┐                ┌─────────────────────────────────────┐             #
#           │ Location A: us-west-2               │                │ Location B: us-east-2               │             #
#           │             Oregon                  │                │             Ohio                    │             #
#           │ ┌─ AZ1 ─────────────────────────┐   │                │ ┌- AZ1 ─────────────────────────┐   │             #
#           │ │ PGD A1 -> pgd1-uswest2        │   │                │ │ PGD B2 -> pgd1-useast2        │   │             #
#           │ │ PGD-Proxy                     │   │                │ │ PGD-Proxy                     │   │             #
#           │ │ Write leader: pgd1-uswest2    │   │                │ │ Write leader: pgd1-useast2    │   │             #
#           │ └───────────────────────────────┘   │                │ └───────────────────────────────┘   │             #
#           │ ┌─ AZ2 ─────────────────────────┐   │◄──────────────►│ ┌─ AZ2 ─────────────────────────┐   │             #
#           │ │ PGD A2 -> pgd2-uswest2        │   │                │ │ PGD B2 -> pgd2-useast2        │   │             #
#           │ │ PGD-Proxy                     │   │                │ │ PGD-Proxy                     │   │             #
#           │ │ Write leader: pgd1-uswest2    │   │                │ │ Write leader: pgd1-useast2    │   │             #
#           │ └───────────────────────────────┘   │                │ └───────────────────────────────┘   │             #
#           │ ┌─ AZ3 ─────────────────────────┐   │                │ ┌- AZ3 ─────────────────────────┐   │             #
#           │ │ PGD A3                        │   │                │ │ PGD B3                        │   │             #
#           │ │ barman-uswest2                │   │                │ │ barman-useast2                │   │             #
#           │ └───────────────────────────────┘   │                │ └───────────────────────────────┘   │             #
#           └─────────────────────────────────────┘                └─────────────────────────────────────┘             #
#                             ▲                                                      ▲                                 #
#                             │                                                      │                                 #
#                             │        ┌─────────────────────────────────────┐       │                                 #
#                             │        │ Location C: us-east-1               │       │                                 #
#                             │        │             Virginia                │       │                                 #
#                             └───────►│ ┌─ AZ1 ─────────────────────────┐   │◄──────┘                                 #
#                                      │ │ witness-useast1               │   │                                         #
#                                      │ └───────────────────────────────┘   │                                         #
#                                      └─────────────────────────────────────┘                                         #
#                                                                                                                      #
########################################################################################################################

. ./config.sh
. /vagrant/repo.sh

#export EDB_SUBSCRIPTION_TOKEN=$repo_credentials

# WARNING: Check subnet association before to start
# https://github.com/EnterpriseDB/se-demos/blob/main/PGD/AWS-Multi-Region/README.md

tpaexec deploy ~/sro-pgdcluster-mr

#aws ec2 describe-instances --query 'Reservations[].Instances[].{InstanceID:InstanceId, State:State.Name, Type:InstanceType}' --output text
