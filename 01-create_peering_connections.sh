#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Create peering connections                                                                              #
# Description: This script must be executed after pgdnetwork provisioning (tpaexec provision pdgnetwork)               #
#              Create peering connections and validate peerings in AWS                                                 #
# PGD infos:                                                                                                           #
#   Virginia: us-east-1 (10.35.0.0/16)                                                                                 #
#   Ohio:     us-east-2 (10.33.0.0/16)                                                                                 #
#   Oregon:   us-west-2 (10.34.0.0/16)                                                                                 #
########################################################################################################################

. ./config.sh

# Clean tmp files used by the script
rm -rf /tmp/*.txt

# Owner Id
owner_id=`aws ec2 describe-vpcs \
  --region us-west-2 \
  --filters Name=tag:Name,Values=PGDUSWEST2 \
  --query "Vpcs[].OwnerId" \
  --output text`

# *********************************
# *** Oregon to Ohio(us-east-2) ***
# *********************************
vpc_id=`aws ec2 describe-vpcs \
  --region us-west-2 \
  --filters Name=tag:Name,Values=PGDUSWEST2 \
  --query "Vpcs[].VpcId" \
  --output text`

# Ohio
peer_vpc_id=`aws ec2 describe-vpcs \
  --region us-east-2 \
  --filters Name=tag:Name,Values=PGDUSEAST2 \
  --query "Vpcs[].VpcId" \
  --output text`

aws ec2 create-vpc-peering-connection \
--peer-owner-id $owner_id \
--peer-vpc-id $peer_vpc_id \
--vpc-id $vpc_id \
--tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=sro-ohio-oregon}]' \
--region us-west-2 \
--peer-region us-east-2 > /tmp/peering_oregon_ohio.txt

vpc_peering_connection_id=`cat /tmp/peering_oregon_ohio.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`

echo "Oregon to Ohio"
echo "owner_id: $owner_id"
echo "vpc_id: $vpc_id"
echo "peer_vpc_id: $peer_vpc_id"
echo "vpc_peering_connection_id: $vpc_peering_connection_id"

sleep 5

aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id $vpc_peering_connection_id \
  --region us-east-2 --no-cli-pager

# *************************************
# *** Oregon to Virginia(us-east-1) ***
# *************************************
vpc_id=`aws ec2 describe-vpcs \
  --region us-west-2 \
  --filters Name=tag:Name,Values=PGDUSWEST2 \
  --query "Vpcs[].VpcId" \
  --output text`

# Virginia
peer_vpc_id=`aws ec2 describe-vpcs \
  --region us-east-1 \
  --filters Name=tag:Name,Values=PGDUSEAST1 \
  --query "Vpcs[].VpcId" \
  --output text`

aws ec2 create-vpc-peering-connection \
--peer-owner-id $owner_id \
--peer-vpc-id $peer_vpc_id \
--vpc-id $vpc_id \
--tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=sro-oregon-virginia}]' \
--region us-west-2 \
--peer-region us-east-1 > /tmp/peering_oregon_virginia.txt

vpc_peering_connection_id=`cat /tmp/peering_oregon_virginia.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`

echo "Oregon to Virginia"
echo "owner_id: $owner_id"
echo "vpc_id: $vpc_id"
echo "peer_vpc_id: $peer_vpc_id"
echo "vpc_peering_connection_id: $vpc_peering_connection_id"

sleep 5

aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id $vpc_peering_connection_id \
  --region us-east-1 --no-cli-pager 

# *************************************
# *** Ohio to Virginia (us-east-1) ***
# *************************************
vpc_id=`aws ec2 describe-vpcs \
  --region us-east-2 \
  --filters Name=tag:Name,Values=PGDUSEAST2 \
  --query "Vpcs[].VpcId" \
  --output text`

# Virginia
peer_vpc_id=`aws ec2 describe-vpcs \
  --region us-east-1 \
  --filters Name=tag:Name,Values=PGDUSEAST1 \
  --query "Vpcs[].VpcId" \
  --output text`

aws ec2 create-vpc-peering-connection \
--region us-east-2 \
--peer-owner-id $owner_id \
--peer-vpc-id $peer_vpc_id \
--vpc-id $vpc_id \
--tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=sro-ohio-virginia}]' \
--peer-region us-east-1  > /tmp/peering_ohio_virginia.txt

vpc_peering_connection_id=`cat /tmp/peering_ohio_virginia.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`

echo "Ohio to Virginia"
echo "owner_id: $owner_id"
echo "vpc_id: $vpc_id"
echo "peer_vpc_id: $peer_vpc_id"
echo "vpc_peering_connection_id: $vpc_peering_connection_id"

sleep 5

aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id $vpc_peering_connection_id \
  --region us-east-1 --no-cli-pager
