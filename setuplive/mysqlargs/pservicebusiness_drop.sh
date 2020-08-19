#!/bin/sh
mapfile -t < /tmp/mysqlScripts/pservicebusiness.txt
source /tmp/mysqlScripts/drop-mysql-tables.sh "${MAPFILE[@]}"
