#!/bin/sh
mapfile -t < /tmp/mysqlScripts/pservice.txt
source /tmp/mysqlScripts/drop-mysql-tables.sh "${MAPFILE[@]}"