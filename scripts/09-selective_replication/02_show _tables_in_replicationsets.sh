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

psql -h pgd1-uswest2,pgd2-uswestt2,pgd1-useast2,pgd2-useastt2 -p 6432 bdrdb -c \
"
SELECT node_group_name, default_repset, parent_group_name
FROM bdr.node_group_summary;

SELECT relname, set_name FROM bdr.tables ORDER BY relname, set_name;
"