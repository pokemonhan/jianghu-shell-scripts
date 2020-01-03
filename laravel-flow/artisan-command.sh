#!/bin/sh
destination_dir="$1"
#/var/www/jianghu_entertain
cd "$destination_dir"
rm -rf composer.lock;
/usr/local/bin/composer install --no-interaction --no-progress --no-ansi --prefer-dist --optimize-autoloader;
php artisan clear-compiled;
php artisan cache:clear;
php artisan route:cache;
php artisan config:cache;
chmod -R 777 ${destination_dir}/storage;