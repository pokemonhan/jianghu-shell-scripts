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
scriptpath="/var/jenkins_workspace/$1"
destination_project="$1"
destination_branch=`echo "$2" | awk -F "/" '{printf "%s", $2}'`
version_prefix='jianghu';
tg_chat_group_id='-356102284';
#get current script directory dynamically
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $dir;
currentScriptDir="${dir##*/}";
#currentScriptDir="${PWD##*/}";
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
##################################################################################
case $Status  in
  Deploy)
    echo "Status:$Status"
    ##################################################################
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
        bash /var/www/$currentScriptDir/submodule/git-submodule-update.sh $destination_dir $destination_branch $destination_host; \
        bash /var/www/$currentScriptDir/laravel-flow/artisan-command.sh $destination_dir; \
        bash /var/www/$currentScriptDir/tag-handle/createTag.sh $destination_dir $tg_chat_group_id; \
        bash /var/www/$currentScriptDir/tag-handle/deletetag.sh $destination_dir; \
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
      ###################
      # PRODUCTION PUSH # production
      ###################
      elif [ "$destination_branch" == "production" ]
      then
          destination_user="$dest_user_prod"
          destination_host="$dest_host_prod"
          destination_dir="$dest_dir_prod"
          pre_prod_dir="$pre_prod"
          # Prep the api doc gen command for production only
          if [ "$gen_docs_prod" == "TRUE" ]
          then
              gen_docs_cmd="php ${gen_docs_proddir}/vendor/bin/apigen generate --source=${destination_dir}/app --destination=${gen_docs_proddir}/public/api --template-theme=bootstrap --title=\"SFS Developer Docs\" -q --tree"
          else
              gen_docs_cmd="whoami"
          fi

          # Get current latest commit running on prod
          ssh -l $destination_user $destination_host "cd $destination_dir;git fetch --all"
          current_local_commit=`ssh -l $destination_user $destination_host "cd $destination_dir;git rev-parse --short HEAD"`
          current_remote_commit=`ssh -l $destination_user $destination_host "cd $destination_dir;git rev-parse --short origin/${destination_branch} "`

          # Make sure local and remote arent the same because then theres no reason to push
          if [ "$current_local_commit" == "$current_remote_commit" ]
          then
              alert_msg="Remote HEAD : $current_remote_commit matches Local HEAD : $current_local_commit, exiting..."
              echo "$alert_msg"
              alert_notification $alert_email "$alert_msg"
              exit 1
          fi

          echo "Commit currently running on production : $current_local_commit"
          echo "Commit currently on remote : $current_remote_commit"

          # Prep the pre prod folder
          check_clear_folder=`ssh -l $destination_user $destination_host "rm -rf $pre_prod_dir"`
          sanity_check $? "Error with cleaning pre prod folder : $check_clear_folder"

          # Clone files from the repo in prod prep folder, set permissions and rsync files from live site
          ssh -l $destination_user $destination_host \
              "mkdir $pre_prod_dir &&\
              cd $pre_prod_dir &&\
              git clone $git_repo . &&\
              rsync --ignore-existing -razp --progress --exclude '.git' --exclude '.npm' --exclude 'node_modules' --exclude 'vendor' --exclude '.cache' ${destination_dir}/ ${pre_prod_dir} &&\
              chown -R ${user_perm}:${group_perm} ${pre_prod_dir}"

          # Sanity checks
          check_composer_install=`ssh -l $destination_user $destination_host "cd $pre_prod_dir;/usr/local/bin/composer install --no-interaction --prefer-dist --optimize-autoloader"`
          sanity_check $? "Error with composer update on production : $check_composer_install"

          # Sanity checks before actually pushing live
          check_npm_install=`ssh -l $destination_user $destination_host "cd $pre_prod_dir;npm i"`
          sanity_check $? "Error with NPM install pacakge on production : $check_npm_install"

          check_npm_run=`ssh -l $destination_user $destination_host "cd $pre_prod_dir;npm run dev"`
          sanity_check $? "Error with NPM run dev on production : $check_npm_run"

          check_move_preprod=`ssh -l $destination_user $destination_host "mv $pre_prod_dir ${destination_dir}_${current_remote_commit}"`
          sanity_check $? "Error with moving pre-prod folder to cluster folder : $check_move_preprod"

          ssh -l $destination_user $destination_host \
              "cd ${destination_dir}_${current_remote_commit};\
              $gen_docs_cmd;\
              php artisan clear-compiled;\
              php artisan cache:clear;\
              php artisan route:clear;\
              php artisan route:cache;\
              php artisan view:clear;\
              php artisan config:clear;\
              php artisan config:cache"

          check_force_symlink=`ssh -l $destination_user $destination_host "ln -sf ${destination_dir}_${current_remote_commit} ${$destination_dir}"`
          sanity_check $? "Error with creating symlink to newly pushed folder : $check_force_symlink"

          # Remove all folders except the current and previous commit folders as well as the symlink
          ssh -l $destination_user $destination_host \
              "find ${dest_dir_root} -type d -not \( -name '${destination_dir}' -or -name '${destination_dir}_{$current_remote_commit}' -or -name '${destination_dir}_${current_local_commit}' \) -delete"

          # We dont run unit tests on production
          echo "" > ${item_rootdir}/tests/results/${destination_project}_test1.xml
          echo "" > ${item_rootdir}/tests/results/${destination_project}_test2.xml

      else
          echo "Invalid branch provided : $destination_branch"
          exit 1
      fi
    ;;
  ##################################################################
  Rollback-Previous)
      echo "Status:$Status"
      echo "Previous to be starting to Rollback"
      if [ "$destination_branch" == "master" ]
      then
          ssh -l $destination_user $destination_host \
              -o PasswordAuthentication=no    \
              -o StrictHostKeyChecking=no     \
              -o UserKnownHostsFile=/dev/null \
              -p 2225                         \
              -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
             "bash /var/www/$currentScriptDir/submodule/revert.sh $destination_dir $currentScriptDir $tg_chat_group_id;"
      else
          echo "Invalid branch provided : $destination_branch to Rollback"
          exit 1
      fi
      ;;
    Rollback)
      echo "Status:$Status"
      echo "Version:$Version to be starting to Rollback"
      if [ "$destination_branch" == "master" ]
      then
          ssh -l $destination_user $destination_host \
              -o PasswordAuthentication=no    \
              -o StrictHostKeyChecking=no     \
              -o UserKnownHostsFile=/dev/null \
              -p 2225                         \
              -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
             "bash /var/www/$currentScriptDir/submodule/revert.sh $destination_dir $currentScriptDir $tg_chat_group_id $Version;"
      else
          echo "Invalid branch provided : $destination_branch to Rollback"
          exit 1
      fi
      ;;
  ##################################################################################
  *)
  exit
      ;;
esac
##################################################################################
