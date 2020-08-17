#!/bin/sh
php -v;
cd /var/www/webapi;
echo $(pwd);
git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout develop-harris-local --
mv phinx.php phinx.php.bak
php vendor/bin/phinx migrate -e production;
mv phinx.php.bak phinx.php
rm -rf /tmp/live_setup;