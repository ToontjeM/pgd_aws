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
INSERT INTO opinion (work_id, attendee_id, country, day, score)
SELECT work.id, attendee.id, 'Italy', '1871-11-19', 3
  FROM work, attendee
 WHERE work.title = 'Lohengrin'
   AND attendee.email = 'gv@example.com';
"

psql -h pgd1-useast2,pgd2-useast2 -p 6432 bdrdb -c \
"
INSERT INTO opinion (work_id, attendee_id, country, day, score)
SELECT work.id, attendee.id, 'Spain', '2024-01-15', 1
  FROM work, attendee
 WHERE work.title = 'Aida';
"
