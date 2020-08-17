#!/bin/sh
MUSER="root"
MPASS="root"
MDB="hswl_live_phinx"
MHOST="localhost"
MYSQL=$(which mysql)
result=$(${MYSQL} -u $MUSER -p$MPASS -h $MHOST --default-character-set=utf8 $MDB < /tmp/mysqlScripts/live_init_data.sql)
echo "$result";
$MYSQL -u $MUSER -p$MPASS -h $MHOST $MDB  -e "UPDATE cmf_user SET user_pass = '###882c2892454ab027a94aba6319a2b655' WHERE id = '1'";
echo "now admin password has set 123qwe";
rm -rf /tmp/mysqlScripts;