currentDir="$1"
current_branch="$2"
destination_host="$3"
cd $currentDir;
git reset --hard;
git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout -b $current_branch origin/$current_branch --;
git reset --hard;
git fetch --all;
git pull origin $current_branch;
git branch;
chmod -R 777 $currentDir;
cat > ${currentDir}/.gitmodules <<EOL
[submodule "phpcs-rule"]
    path = phpcs-rule
    url = ssh://git@${destination_host}:2289/php/phpcs-rule.git
[submodule "jianghu_entertain_composer"]
	path = jianghu_entertain_composer
	url = ssh://git@${destination_host}:2289/php/jianghu_entertain_composer.git
EOL
    chmod 777 ${currentDir}/.gitmodules;
    if [[ ! -e ${currentDir}/phpcs-rule ]]; then
        git submodule add -f ssh://git@${destination_host}:2289/php/phpcs-rule.git phpcs-rule;
    fi;
    if [[ ! -e ${currentDir}/jianghu_entertain_composer ]]; then
        git submodule add -f ssh://git@${destination_host}:2289/php/jianghu_entertain_composer.git jianghu_entertain_composer;
    fi;
#    git submodule update --init --recursive
    git submodule foreach --recursive git clean -d -f -f -x
    chmod 777 ${currentDir}/phpcs-rule;
    cd ${currentDir}/phpcs-rule;
    git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout master --;
    git -c credential.helper= -c core.quotepath=false -c log.showSignature=false fetch origin --progress --prune;
    git pull origin master;
    chmod 777 ${currentDir}/jianghu_entertain_composer;
    cd ${currentDir}/jianghu_entertain_composer;
    git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout master --;
    git -c credential.helper= -c core.quotepath=false -c log.showSignature=false fetch origin --progress --prune;
    git pull origin master;
    chmod -R 777 $currentDir;
    if [ ! -f "${currentDir}/composer.json" ]; then
            cp ${currentDir}/jianghu_entertain_composer/composer.json ${currentDir}/composer.json;
    fi