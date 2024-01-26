#!/bin/bash
. ../primary_node.sh

psql -h $primary -p 6432 bdrdb -c "DELETE ping;"
