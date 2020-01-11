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
ln -s ../jianghu_entertain_composer/composer.json composer.json
/usr/local/bin/composer install --no-interaction --no-progress --no-ansi --prefer-dist --optimize-autoloader;
php artisan clear-compiled;
php artisan lang:publish zh-CN --force;
case $isSeed in
  1|2)
   php artisan migrate:fresh --seed;
  ;;
esac
php artisan cache:clear;
php artisan route:cache;
php artisan config:cache;
chmod -R 777 ${destination_dir}/storage;