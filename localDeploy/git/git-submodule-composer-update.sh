#!/bin/sh
destination_dir="$1"
destination_host="$2"
#/var/www/jianghu_entertain
cd "$destination_dir"
rm -rf ${destination_dir}/jianghu_entertain_composer;
git clone ssh://git@${destination_host}:2289/php/jianghu_entertain_composer.git
chmod 777 ${destination_dir}/jianghu_entertain_composer;
cd ${destination_dir}/jianghu_entertain_composer;
git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout master --;
git -c credential.helper= -c core.quotepath=false -c log.showSignature=false fetch origin --progress --prune;
git pull origin master;
rm -f ${destination_dir}/.gitmodules;
cp -f ${destination_dir}/jianghu_entertain_composer/composer.json ${destination_dir}/
rm -rf ${destination_dir}/jianghu_entertain_composer;