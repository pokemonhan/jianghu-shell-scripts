#!/bin/sh
mapfile -t < /tmp/mysqlScripts/live_game.txt
source /tmp/mysqlScripts/drop-mysql-tables.sh "${MAPFILE[@]}"
rm -rf /tmp/mysqlScripts;
