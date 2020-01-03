#!/bin/sh
destination_dir="$1"
destination_branch="$2"
destination_host="$3"
#/var/www/jianghu_entertain
cd "$destination_dir"
git reset --hard origin/$destination_branch;
git fetch --all;
git checkout -f $destination_branch;
git reset --hard;
git fetch --all;
git pull origin $destination_branch;
              cat > ${destination_dir}/.gitmodules <<EOL
[submodule "phpcs-rule"]
    path = phpcs-rule
    url = ssh://git@${destination_host}:2289/php/phpcs-rule.git
EOL
        chmod 777 ${destination_dir}/.gitmodules;
        if [[ ! -e ${destination_dir}/phpcs-rule ]]; then
            git submodule add -f ssh://git@${destination_host}:2289/php/phpcs-rule.git phpcs-rule;
        fi;
        git submodule init;
        git submodule sync;
        chmod 777 ${destination_dir}/phpcs-rule;
        cd ${destination_dir}/phpcs-rule;
        git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout master --;
        git -c credential.helper= -c core.quotepath=false -c log.showSignature=false fetch origin --progress --prune;
        git pull origin master;