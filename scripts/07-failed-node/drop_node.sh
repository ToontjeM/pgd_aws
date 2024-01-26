#!/bin/bash

psql bdrdb -c "select bdr.part_node('pgd3-useast2');"
psql bdrdb -c "select bdr.drop_node('pgd3-useast2');"