#!/bin/sh
php -v;
cd /var/www/web-api;
echo $(pwd);
git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout develop-harris-local --

function runScripts() {
  echo $(eachCommand "php /var/www/web-api/server.php tool:init_services_data" "数据初始化");
  echo $(eachCommand "php /var/www/web-api/server.php permission:init" "权限初始化");
  echo $(eachCommand "chmod +x /var/www/web-api/script/permission/service.sh" "shell 脚本 权限添加");
  echo $(eachCommand "sh /var/www/web-api/script/permission/service.sh" "执行权限升级");
  echo $(eachCommand "php /var/www/web-api/server.php menu:delete 'Icon Manage' 1" "删除图标管理菜单");
  echo $(eachCommand "php /var/www/web-api/server.php menu:delete 'Platform Announcement Management' 1" "删除平台公告菜单");
  echo $(eachCommand "php /var/www/web-api/server.php menu:delete 'Service Match Management' 1" "删除平台赛事管理菜单");
  echo $(eachCommand "php /var/www/web-api/server.php menu:delete 'Handicap Management' 1" "删除平台盘口管理菜单");
  echo $(eachCommand "php /var/www/web-api/server.php menu:delete 'Service Parameters Settings' 1" "删除平台玩法参数管理菜单");
}

function eachCommand() {
    local result=$(sh -c "$1");
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        echo "Status is $STATUS";
        echo "$result";
        echo "执行: $1 异常[$2]"
        exit 0
    fi
    echo "Status is $STATUS";
    echo "$result";
    echo "===================================";
    echo "执行: $1 完成";
}

#mv phinx.php phinx.php.bak
cp -f phinx-business.yml phinx.yml;
php vendor/bin/phinx migrate -e production;
echo "Business Related DB have been migrated";
cp -f phinx-service.yml phinx.yml;
php vendor/bin/phinx migrate -e production;
echo "Service Related DB have been migrated";
echo "$(runScripts)";
cp -f phinx-payment.yml phinx.yml;
php vendor/bin/phinx migrate -e production;
echo "Payment Related DB have been migrated";
#mv phinx.php.bak phinx.php
rm -rf /tmp/pservice_setup;