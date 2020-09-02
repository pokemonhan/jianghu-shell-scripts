#!/bin/sh
cd /var/www/webapi;
git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout develop-migration-local --
echo $(pwd);
rm -rf vendor;
rm -f composer.lock;
composer install;
vendor/bin/phinx-migrations generate -e production;
rm -rf /tmp/*;