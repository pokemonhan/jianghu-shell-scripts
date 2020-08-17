#!/bin/sh
MUSER="root"
MPASS="root"
MDB="hswl_live_game"
MHOST="localhost"
MYSQL=$(which mysql)
$MYSQL -u $MUSER -p$MPASS -h $MHOST --default-character-set=utf8 $MDB < /tmp/mysqlScripts/hswl_live_game.sql;
$MYSQL -u $MUSER -p$MPASS -h $MHOST --default-character-set=utf8 $MDB < /tmp/mysqlScripts/hswl_live_game_data.sql;
rm -rf /tmp/mysqlScripts;