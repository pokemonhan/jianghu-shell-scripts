#!/bin/sh
mapfile -t < /tmp/mysqlScripts/pservicepay.txt
source /tmp/mysqlScripts/drop-mysql-tables.sh "${MAPFILE[@]}"
