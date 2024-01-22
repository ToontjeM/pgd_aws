#!/bin/bash

########################################################################################################################
# Author:      Sergio Romera                                                                                           #
# Date:        15/01/2024                                                                                              #
# Subject:     Subnect association                                                                                     #
# Description: This script must be executed after script after pgdcluster provisioning                                 #
#              Disassociate from pgdcluster and associate subnets to pgdnetwork route table                            #
########################################################################################################################

# **************
# *** Oregon ***
# **************
region=us-west-2

route_table_id=`aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=sro-pgdnetwork/us-west-2/routes' \
  --query "RouteTables[].RouteTableId" \
  --output text`

aws ec2 describe-subnets \
  --filters 'Name=tag:Name,Values=uswest2*' \
  --region $region | \
  jq -r .Subnets[].SubnetId > /tmp/subnets_oregon.txt


aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=*pgdcluster*' \
  | jq -r .RouteTables[].Associations[].RouteTableAssociationId > /tmp/routetable_assotiation_ids_oregon.txt

while read -r line;
do
  aws ec2 disassociate-route-table --association-id $line \
  --region $region
done < /tmp/routetable_assotiation_ids_oregon.txt

while read -r line;
do
  aws ec2 associate-route-table \
    --route-table-id $route_table_id \
    --region $region \
    --subnet-id $line
done < /tmp/subnets_oregon.txt

# ************
# *** Ohio ***
# ************
region=us-east-2

route_table_id=`aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=sro-pgdnetwork/us-east-2/routes' \
  --query "RouteTables[].RouteTableId" \
  --output text`

aws ec2 describe-subnets \
  --filters 'Name=tag:Name,Values=useast2*' \
  --region $region | \
  jq -r .Subnets[].SubnetId > /tmp/subnets_ohio.txt


aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=*pgdcluster*' \
  | jq -r .RouteTables[].Associations[].RouteTableAssociationId > /tmp/routetable_assotiation_ids_ohio.txt

while read -r line;
do
  aws ec2 disassociate-route-table --association-id $line \
    --region $region
done < /tmp/routetable_assotiation_ids_ohio.txt

while read -r line;
do
  aws ec2 associate-route-table \
    --route-table-id $route_table_id \
    --region $region \
    --subnet-id $line
done < /tmp/subnets_ohio.txt

# ****************
# *** Virginia ***
# ****************
region=us-east-1

route_table_id=`aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=sro-pgdnetwork/us-east-1/routes' \
  --query "RouteTables[].RouteTableId" \
  --output text`

aws ec2 describe-subnets \
  --filters 'Name=tag:Name,Values=useast1*' \
  --region $region | \
  jq -r .Subnets[].SubnetId > /tmp/subnets_virginia.txt


aws ec2 describe-route-tables \
  --region $region \
  --filters 'Name=tag:Name,Values=*pgdcluster*' \
  | jq -r .RouteTables[].Associations[].RouteTableAssociationId > /tmp/routetable_assotiation_ids_virginia.txt

while read -r line;
do
  aws ec2 disassociate-route-table --association-id $line \
    --region $region
done < /tmp/routetable_assotiation_ids_virginia.txt

while read -r line;
do
  aws ec2 associate-route-table \
    --route-table-id $route_table_id \
    --region $region \
    --subnet-id $line
done < /tmp/subnets_virginia.txt
