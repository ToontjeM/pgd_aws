#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Create routes in AWS                                                                                    #
# Description: This script create routes in each VPC                                                                   #
########################################################################################################################

. ./config.sh

# **************
# *** Oregon ***
# **************
region=us-west-2

route_table_id=`aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=sro-pgdnetwork/us-west-2/routes' \
  --query "RouteTables[].RouteTableId" \
  --output text`

# Route Oregon to Virginia (35 - us-east-1)
vpc_peering_connection_id=`cat /tmp/peering_oregon_virginia.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`
aws ec2 create-route \
  --route-table-id $route_table_id \
  --region $region \
  --destination-cidr-block 10.35.0.0/16 \
  --vpc-peering-connection-id $vpc_peering_connection_id

# Route Oregon to Ohio (33 - us-east-2)
vpc_peering_connection_id=`cat /tmp/peering_oregon_ohio.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`
aws ec2 create-route \
  --route-table-id $route_table_id \
  --region $region \
  --destination-cidr-block 10.33.0.0/16 \
  --vpc-peering-connection-id $vpc_peering_connection_id

# ************
# *** Ohio ***
# ************
region=us-east-2

route_table_id=`aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=sro-pgdnetwork/us-east-2/routes' \
  --query "RouteTables[].RouteTableId" \
  --output text`

# Route Ohio to Virginia (35 - us-east-1)
vpc_peering_connection_id=`cat /tmp/peering_ohio_virginia.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`
aws ec2 create-route \
  --route-table-id $route_table_id \
  --region $region \
  --destination-cidr-block 10.35.0.0/16 \
  --vpc-peering-connection-id $vpc_peering_connection_id

# Route Ohio to Oregon (34 - us-west-2)
vpc_peering_connection_id=`cat /tmp/peering_oregon_ohio.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`
aws ec2 create-route \
  --route-table-id $route_table_id \
  --region $region \
  --destination-cidr-block 10.34.0.0/16 \
  --vpc-peering-connection-id $vpc_peering_connection_id

# ****************
# *** Virginia ***
# ****************
region=us-east-1

route_table_id=`aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=sro-pgdnetwork/us-east-1/routes' \
  --query "RouteTables[].RouteTableId" \
  --output text`

# Route Virginia to Oregon (34 - us-west-2)
vpc_peering_connection_id=`cat /tmp/peering_oregon_virginia.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`
aws ec2 create-route \
  --route-table-id $route_table_id \
  --region $region \
  --destination-cidr-block 10.34.0.0/16 \
  --vpc-peering-connection-id $vpc_peering_connection_id

# Route Virginia to Ohio (33 - us-east-2)
vpc_peering_connection_id=`cat /tmp/peering_ohio_virginia.txt | jq -r .VpcPeeringConnection.VpcPeeringConnectionId`
aws ec2 create-route \
  --route-table-id $route_table_id \
  --region $region \
  --destination-cidr-block 10.33.0.0/16 \
  --vpc-peering-connection-id $vpc_peering_connection_id

