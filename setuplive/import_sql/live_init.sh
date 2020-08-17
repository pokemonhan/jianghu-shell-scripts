#!/bin/sh
mysql -uroot -proot hswl_live_phinx -e "statement" < /tmp/mysqlScripts/live_init_data.sql