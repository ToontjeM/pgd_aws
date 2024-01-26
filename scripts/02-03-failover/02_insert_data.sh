#!/bin/bash

while true; 
do psql -h pgd1-useast2,pgd2-useast2,pgd1-uswest2,pgd2-uswestt2 -p 6432 bdrdb -c \
"select node_name CONNECTED_TO from bdr.local_node_summary;
INSERT INTO ping(node, timestamp) select node_name, current_timestamp from bdr.local_node_summary;" && sleep 3
done

