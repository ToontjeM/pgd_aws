#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Config file                                                                                             #
# Description: Setup AWS variables and some useful functions                                                           #
########################################################################################################################

source ./repo.sh

function show_instances()
{
  arr=("us-east-1" "us-east-2" "us-west-2")
  i=0
  len=${#arr[@]}
  while [ $i -lt $len ];
  #while read -r region
  do
    region=${arr[$i]}
    echo "***************************"
    echo "Region: $region"
    echo "***************************"
    instances=`aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].InstanceId" --output text --region=$region > /tmp/instances.txt`
    while read -r instance
    do
      #echo "instance: $instance"
      printf "+ " && aws ec2 describe-tags --filters Name=resource-id,Values=$instance Name=key,Values=Name --query Tags[].Value --output text --region=$region
    done < /tmp/instances.txt
    let i++  
  done
}

#vpc
#aws ec2 --query 'Vpcs[*].{a:Tags[?Key==Name].Value|[0], b:VpcId, Cidr:CidrBlockAssociationSet[*].CidrBlock}' describe-vpcs --output text
#None    vpc-0c4da3eade81d25d6
#CIDR    10.0.0.0/16
#None    vpc-05106132be2205420
#CIDR    10.33.0.0/16

