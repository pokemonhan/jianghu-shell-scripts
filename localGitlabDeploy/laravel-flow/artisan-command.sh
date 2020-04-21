#!/bin/sh
destination_dir="$1"
function execFile()
{
	echo "current file is $1"
	set -f; IFS='/'
	set -- $1
	# outer.txt
	# database/seeds/seeds.txt
	# database/migrations/mg
	# echo "dir1 is $1,dir2 is $2,dir3 is $3"
	case $2 in
		seeds)
		 isSeed=2
		;;
		migrations)
		if [[ $isSeed -lt 1 ]]; then
			isSeed=1
		fi
		;;
	esac
	set +f; unset IFS
	IFS=$'\n'       # make newlines the only separator
	set -f
}
function checkIfMigration()
{
	listsTag=$(git show --pretty="format:" --name-only $(git describe --tags --abbrev=0)..HEAD)
	IFS=$'\n'       # make newlines the only separator
	set -f
	isSeed=0
	for line in $listsTag
	do
		execFile $line
	done
	set +f; unset IFS
	# disable globbing
}
#/var/www/jianghu_entertain
cd "$destination_dir"
checkIfMigration
echo "isSeed is now $isSeed"
rm -rf composer.lock;
cp -f jianghu_entertain_composer/composer.json composer.json
###########################update composer every 6hour #############################################################
updatelocation='/var/www/tmp/composer-daily.log'
if [ ! -f $updatelocation ]; then
    mkdir -m 777 -p "$(dirname "$updatelocation")" || exit
    touch "$updatelocation"
    echo "composer update first time trigger"
    /usr/local/bin/composer install --no-interaction --no-progress --no-ansi --prefer-dist --optimize-autoloader;
else
    if [[ $(find "$updatelocation" -mmin +360 -print) ]]; then
        echo "File $updatelocation exists and is older than 6 hours"
        rm -f $updatelocation
        mkdir -m 777 -p "$(dirname "$updatelocation")" || exit
        touch "$updatelocation"
        echo "composer has not been update for 6 hours lets update ..."
        /usr/local/bin/composer install --no-interaction --no-progress --no-ansi --prefer-dist --optimize-autoloader;
    else
      echo "composer update will do later 6 hours after"
      /usr/local/bin/composer dump-autoload;
    fi
fi
####################################################################################################################
php artisan clear-compiled;
php artisan lang:publish zh-CN --force;
case $isSeed in
  1|2)
   php artisan modelCache:clear;
   php artisan migrate:fresh --seed;
  ;;
esac
php artisan cache:clear;
php artisan route:cache;
php artisan config:cache;
php artisan queue:restart
chmod -R 777 ${destination_dir}/storage;