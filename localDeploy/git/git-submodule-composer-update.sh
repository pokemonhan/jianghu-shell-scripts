#!/bin/sh
destination_dir="$1"
destination_branch="$2"
destination_host="$3"
#/var/www/jianghu_entertain
cd "$destination_dir"
              cat > ${destination_dir}/.gitmodules <<EOL
[submodule "jianghu_entertain_composer"]
	path = jianghu_entertain_composer
	url = ssh://git@${destination_host}:2289/php/jianghu_entertain_composer.git
EOL
        chmod 777 ${destination_dir}/.gitmodules;
        if [[ ! -e ${destination_dir}/jianghu_entertain_composer ]]; then
            git submodule add -f ssh://git@${destination_host}:2289/php/jianghu_entertain_composer.git jianghu_entertain_composer;
        fi;
        git submodule init;
        git submodule sync;
        chmod 777 ${destination_dir}/jianghu_entertain_composer;
        cd ${destination_dir}/jianghu_entertain_composer;
        git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout master --;
        git -c credential.helper= -c core.quotepath=false -c log.showSignature=false fetch origin --progress --prune;
        git pull origin master;