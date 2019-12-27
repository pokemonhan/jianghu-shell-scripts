#!/bin/sh

#check command input
if [ "$#" -ne 2 ];
then
        echo "JENKINS LARAVEL PUSH"
        echo "--------------------"
        echo ""
        echo "Usage : ./jenkins-laravel.sh project-name"
        echo ""
        exit 1
fi
# Declare variables
currentdate=`date "+%Y-%m-%d"`
scriptpath="/var/jenkins_workspace/jianghu_php"
destination_project="$1"
destination_branch=`echo "$2" | awk -F "/" '{printf "%s", $2}'`
version_prefix='jianghu';
tg_chat_group_id='-356102284';

# Get configuration variables
echo "Config files is ${scriptpath}/${destination_project}.conf"
source ${scriptpath}/${destination_project}.conf
echo "Pushing to $destination_branch .. "

# Declare functions
alert_notification() {
    echo "Push script failure : $2" | mail -s "Push script Failure" $1
}

sanity_check() {
    if [ $1 -ne 0 ]
    then
        echo "$2"
        alert_notification $alert_email "$2"
        exit 1
    fi
}
echo
##################################################################################
destination_user="$dest_user_staging"
destination_host="$dest_host_staging" #$dest_host_staging　
destination_dir="$dest_dir_staging"
gitlabip="172.19.0.1" # 172.22.0.1　9170ttt.com
#     UPSTREAM=${1:-'@{u}'}
#     LOCAL=$(git rev-parse @)
#     REMOTE=$(git rev-parse "$UPSTREAM")
#     BASE=$(git merge-base @ "$UPSTREAM")
#
#     if [ $LOCAL = $REMOTE ]; then
#       echo "Up-to-date"
#     elif [ $LOCAL = $BASE ]; then
#       echo "Need to pull"
#     elif [ $REMOTE = $BASE ]; then
#       echo "Need to push"
#     else
#       echo "Diverged"
#     fi
#******************************
#git ls-remote $(git rev-parse --abbrev-ref @{u} | \sed 's/\// /g') | cut -f1
      ################
      # STAGING PUSH #
      ################
      if [ "$destination_branch" == "master" ]
      then
          # Push command over ssh
          ssh -l $destination_user $destination_host \
              -o PasswordAuthentication=no    \
              -o StrictHostKeyChecking=no     \
              -o UserKnownHostsFile=/dev/null \
              -p 2225                         \
              -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
             "cd $destination_dir;\
              echo \"\${1:-'@{u}'}\"\;
              UPSTREAM=\${1:-'@{u}'};\
                echo \"UPSTREAM is \$UPSTREAM\";\
              LOCAL=\"\$(git rev-parse @)\";\
                echo \"LOCAL is \$LOCAL\";\
              REMOTE=\$(git ls-remote \$(git rev-parse --abbrev-ref @{u} | \sed 's/\// /g') | cut -f1);\
                echo \"REMOTE is \$REMOTE\";\
              if [[ \$LOCAL != \$REMOTE ]] || [[ -z \$REMOTE ]] ; then \
              git reset --hard origin/$destination_branch;\
              git fetch --all;\
              git checkout -f $destination_branch;\
              git reset --hard;\
              git fetch --all;\
              git pull origin $destination_branch;\
              cat > ${destination_dir}/.gitmodules <<EOL
[submodule \"phpcs-rule\"]
    path = phpcs-rule
    url = ssh://git@${destination_host}:2289/php/phpcs-rule.git
EOL
        chmod 777 ${destination_dir}/.gitmodules;\
        if [[ ! -e ${destination_dir}/phpcs-rule ]]; then \
            git submodule add -f ssh://git@${destination_host}:2289/php/phpcs-rule.git phpcs-rule;\
        fi;\
        git submodule init;\
        git submodule sync;\
        chmod 777 ${destination_dir}/phpcs-rule;\
        cd ${destination_dir}/phpcs-rule;\
        git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout master --;\
        git -c credential.helper= -c core.quotepath=false -c log.showSignature=false fetch origin --progress --prune;\
        git pull origin master;\
        cd $destination_dir;\
              rm -rf composer.lock;\
              git tag -l | xargs git tag -d && git fetch -t;\
              /usr/local/bin/composer install --no-interaction --no-progress --no-ansi --prefer-dist --optimize-autoloader;\
              php artisan clear-compiled;\
              php artisan cache:clear;\
              php artisan route:cache;\
              php artisan config:cache;\
              chmod -R 777 ${destination_dir}/storage;\
              counter=0;\
                while [ \$counter -lt 20 ]
                do
                  message=\"\$(git log -1 --skip \$counter --pretty=%B)\"
                  if [[ \${message} == *\"Merge\"* ]]; then
                   echo here is in merge \"\${message}\";
                    ((counter++))
                   else
                   echo here is normal msg \"\${message}\";
                      break
                   fi
                  echo count is \$counter and message is \$message
                done
              echo tag message now is \${message};\
              git tag -l $version_prefix-$BUILD_NUMBER;\
              git tag -a $version_prefix-$BUILD_NUMBER -f -m \"\${message}\";\
              git push --follow-tags;\
              cd /var/www/telegram-bot-bash;\
              export BASHBOT_HOME=\"\$(pwd)\";\
              source ./bashbot.sh source;\
              startEmoji=\"🤩🤩🤩🤩🤩🤩\";\
              telegrammsg=\$startEmoji\"[ 已发布版本:$version_prefix-$BUILD_NUMBER ]\$startEmoji\n\n[ 发布摘要:\$message ]\";\
              send_message $tg_chat_group_id \"\$telegrammsg\";\
else\
    echo \"Nothing to do\";
fi;\
              "
              #chmod -R 775 ${destination_dir};\
              #php artisan config:cache;"
              #php artisan migrate --force;\
              #php artisan queue:restart;\
              #npm i;\
              #npm run dev;\
              #php artisan config:clear;\
              #/usr/bin/php ./vendor/bin/phpunit --log-junit ${destination_dir}/tests/results/${destination_project}_test1.xml"

          # Get test results
      #    ssh -l $destination_user $destination_host \
      #        -o PasswordAuthentication=no    \
      #        -o StrictHostKeyChecking=no     \
      #        -o UserKnownHostsFile=/dev/null \
      #        -p 2225                         \
      #        -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
      #        "cat ${destination_dir}/tests/results/${destination_project}_test1.xml" > ${item_rootdir}/tests/results/${destination_project}_test1.xml

      echo "Completing Build!"
 fi;
##################################################################################