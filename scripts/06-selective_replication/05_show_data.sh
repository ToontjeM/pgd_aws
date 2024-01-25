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

psql -h pgd1-uswest2,pgd2-uswest2 -p 6432 bdrdb -c \
"
select node_name CONNECTED_TO from bdr.local_node_summary;
select * from opinion;
SELECT a.email
, o.country
, o.day
, w.title
, w.author
, o.score
FROM opinion o
JOIN work w ON w.id = o.work_id
JOIN attendee a ON a.id = o.attendee_id;
"
echo "=======================+
psql -h pgd1-useast2,pgd2-useast2 -p 6432 bdrdb -c \
"
select node_name CONNECTED_TO from bdr.local_node_summary;
select * from opinion;
SELECT a.email
, o.country
, o.day
, w.title
, w.author
, o.score
FROM opinion o
JOIN work w ON w.id = o.work_id
JOIN attendee a ON a.id = o.attendee_id;
"
