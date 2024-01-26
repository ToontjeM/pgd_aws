#!/bin/bash
. ../primary_node.sh

psql -h $primary -p 6432 bdrdb -c \
"drop table if exists ping cascade;
CREATE TABLE ping (id SERIAL PRIMARY KEY, node TEXT, timestamp TEXT) ;"

