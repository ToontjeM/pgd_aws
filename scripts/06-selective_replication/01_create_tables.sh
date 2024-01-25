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
drop table if exists attendee cascade;
CREATE TABLE attendee (
   id bigserial PRIMARY KEY, 
   email text NOT NULL
);

drop table if exists work cascade;
CREATE TABLE work (
    id int PRIMARY KEY,
    title text NOT NULL,
    author text NOT NULL
);

drop table if exists opinion cascade;
CREATE TABLE opinion (
    id bigserial PRIMARY KEY,
    work_id int NOT NULL REFERENCES work(id),
    attendee_id bigint NOT NULL REFERENCES attendee(id),
    country text NOT NULL,
    day date NOT NULL,
    score int NOT NULL
);
"