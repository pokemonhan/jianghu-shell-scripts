#!/bin/sh
# Declare variables
currentdate=`date "+%Y-%m-%d"`
# Just show the output:
set -
# change dir to where this builds files are kept:
#cd /var/jenkins_home/jobs/local_alvin/builds/${BUILD_NUMBER}
## To start, just get the whole string from the 'log' file:
#export STARTED_BY="`grep -i Started log`"
## Output it to the console:
#echo "STARTED BY USER = ${STARTED_BY}"
## refine this to just the user name:
#export JUST_NAME="`echo "${STARTED_BY}" | sed "s@Started by user@@"`"
#
#echo "$JUST_NAME" | sed -e 's/^[@ \t]*//';
#Name="$JUST_NAME" | sed -e 's/^[ \t]*//';
#echo "now Name is $Name";
#echo "Jenkins User Name is ${JUST_NAME}";

echo "Full name (first name + last name) $BUILD_USER";
echo "First name $BUILD_USER_FIRST_NAME";
echo "Last name $BUILD_USER_LAST_NAME";
echo "Jenkins user ID $BUILD_USER_ID";
echo "Email address $BUILD_USER_EMAIL";

shareprj='/var/www/shareprj';
tailPath='site/jianghu_entertain';
destination_host='172.19.0.1';
destination_user='root';
#get current script directory dynamically
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $dir;
currentScriptDir="${dir##*/}";
case $BUILD_USER_FIRST_NAME in
   "Harris")
   dirUser="harris";
   destination_dir="$shareprj/$dirUser/$tailPath"
      ;;
    "Alvin")
    dirUser='alvinphp';
   destination_dir="$shareprj/$dirUser/$tailPath"
      ;;
    "taibo")
   dirUser='taibophp';
   destination_dir="$shareprj/$dirUser/$tailPath"
      ;;
    "ethan")
   dirUser='ethan';
   destination_dir="$shareprj/$dirUser/$tailPath"
      ;;
   *)
     echo "FFFFFFFFFF";
     ;;
esac
case $Type  in
  Deploy)
    echo "Type is :$Type"
#    echo "Action Name is : $ActionName";
#    echo "Request Name is : $RequestName";
#    echo "Artisan Command is : $ArtisanCommand";
#chown -R ${dirUser}:${dirUser} ${destination_dir}/*;\
    ssh -l $destination_user $destination_host \
                  -o PasswordAuthentication=no    \
                  -o StrictHostKeyChecking=no     \
                  -o UserKnownHostsFile=/dev/null \
                  -p 2225                         \
                  -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
                 "cd $destination_dir;\
                 bash /var/www/$currentScriptDir/localDeploy/git/git-submodule-composer-update.sh $destination_dir; \
                 /usr/local/bin/composer install --no-interaction --no-progress --no-ansi --prefer-dist --optimize-autoloader;\
                  php artisan clear-compiled;\
                  php artisan cache:clear;\
                  php artisan route:cache;\
                  php artisan config:cache;\
                  chmod -R 777 ${destination_dir}/storage;\
                  chmod -R 777 ${destination_dir}/vendor;\
                  GET_COMMAND=\"ls -ld $destination_dir\";\
                  GETCOMMND_RESULT=\$(\$GET_COMMAND);\
                  OWNER=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=3);\
                  GROUP=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=4);\
                  echo ow is \$OWNER;\
                  echo gp is \$GROUP;\
                  chown -R \$OWNER:\$GROUP $destination_dir/*;\
                  rm -f $destination_dir/composer.json $destination_dir/composer.lock;\
"
    ##################################################################
    ;;
  "Composer Update")
      echo "Type is :$Type"
#    echo "Action Name is : $ActionName";
#    echo "Request Name is : $RequestName";
#    echo "Artisan Command is : $ArtisanCommand";
    ssh -l $destination_user $destination_host \
                  -o PasswordAuthentication=no    \
                  -o StrictHostKeyChecking=no     \
                  -o UserKnownHostsFile=/dev/null \
                  -p 2225                         \
                  -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
                 "cd $destination_dir;\
                 bash /var/www/$currentScriptDir/localDeploy/git/git-submodule-composer-update.sh $destination_dir; \
                 /usr/local/bin/composer update --no-interaction --no-progress --no-ansi;\
                  php artisan clear-compiled;\
                  php artisan config:cache;\
                  chmod -R 777 ${destination_dir}/storage;\
                  chmod -R 777 ${destination_dir}/vendor;\
                  GET_COMMAND=\"ls -ld $destination_dir\";\
                  GETCOMMND_RESULT=\$(\$GET_COMMAND);\
                  OWNER=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=3);\
                  GROUP=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=4);\
                  echo ow is \$OWNER;\
                  echo gp is \$GROUP;\
                  chown -R \$OWNER:\$GROUP $destination_dir/*;\
                  rm -f $destination_dir/composer.json $destination_dir/composer.lock;\
"
  ;;
  "Clear Cache")
      echo "Type is :$Type"
#      echo "Action Name is : $ActionName";
#      echo "Request Name is : $RequestName";
#      echo "Artisan Command is : $ArtisanCommand";
       ssh -l $destination_user $destination_host \
                        -o PasswordAuthentication=no    \
                        -o StrictHostKeyChecking=no     \
                        -o UserKnownHostsFile=/dev/null \
                        -p 2225                         \
                        -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
                       "cd $destination_dir;\
                       bash /var/www/$currentScriptDir/localDeploy/git/git-submodule-composer-update.sh $destination_dir; \
                        php artisan clear-compiled;\
                        php artisan cache:clear;\
                        php artisan route:cache;\
                        php artisan config:cache;\
                        chmod -R 777 ${destination_dir}/storage;\
                        chmod -R 777 ${destination_dir}/vendor;\
                       GET_COMMAND=\"ls -ld $destination_dir\";\
                       GETCOMMND_RESULT=\$(\$GET_COMMAND);\
                       OWNER=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=3);\
                       GROUP=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=4);\
                       echo ow is \$OWNER;\
                       echo gp is \$GROUP;\
                       chown -R \$OWNER:\$GROUP $destination_dir/*;\
                       rm -f $destination_dir/composer.json $destination_dir/composer.lock;\
"
  ;;

#ssh -l root 172.19.0.1 \
#                   -o PasswordAuthentication=no    \
#                   -o StrictHostKeyChecking=no     \
#                   -o UserKnownHostsFile=/dev/null \
#                   -p 2225                         \
#                   -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
#                  "cd /var/www/shareprj/ethan/site/jianghu_entertain;\
#                   GET_COMMAND=\"ls -ld /var/www/shareprj/ethan/site/jianghu_entertain\";\
#                   echo \$GET_COMMAND;\
#                   GETCOMMND_RESULT=\$(\$GET_COMMAND);\
#                   echo \$GETCOMMND_RESULT;\
#                   OWNER=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=3);\
#                   GROUP=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=4);\
#                   echo owner is \$OWNER;\
#                   echo group is \$GROUP;\
#   "

  "Dump Autoload")
      echo "Type is :$Type"
    echo "Action Name is : $ActionName";
    echo "Request Name is : $RequestName";
    echo "Artisan Command is : $ArtisanCommand";
    ssh -l $destination_user $destination_host \
                      -o PasswordAuthentication=no    \
                      -o StrictHostKeyChecking=no     \
                      -o UserKnownHostsFile=/dev/null \
                      -p 2225                         \
                      -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
                     "cd $destination_dir;\
                     bash /var/www/$currentScriptDir/localDeploy/git/git-submodule-composer-update.sh $destination_dir; \
                     /usr/local/bin/composer dump-autoload;\
                     chmod -R 777 ${destination_dir}/storage;\
                     chmod -R 777 ${destination_dir}/vendor;\
                     GET_COMMAND=\"ls -ld $destination_dir\";\
                     GETCOMMND_RESULT=\$(\$GET_COMMAND);\
                     OWNER=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=3);\
                     GROUP=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=4);\
                     echo ow is \$OWNER;\
                     echo gp is \$GROUP;\
                     chown -R \$OWNER:\$GROUP $destination_dir/*;\
                     rm -f $destination_dir/composer.json $destination_dir/composer.lock;\
                      "
    ;;
  "Create Action")
      echo "Type is :$Type"
#    echo "Action Name is : $ActionName";
    echo "Request Name is : $RequestName";
#    echo "Artisan Command is : $ArtisanCommand";
if [ -z "$RequestName" ]
then
      echo "Only ActionName";
      ActionCommand="php artisan make:action $ActionName";
else
      echo "With RequestName";
      ActionCommand="php artisan make:action $ActionName --r";
fi
    ssh -l $destination_user $destination_host \
                          -o PasswordAuthentication=no    \
                          -o StrictHostKeyChecking=no     \
                          -o UserKnownHostsFile=/dev/null \
                          -p 2225                         \
                          -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
                         "cd $destination_dir;\
                         bash /var/www/$currentScriptDir/localDeploy/git/git-submodule-composer-update.sh $destination_dir; \
                         $ActionCommand;\
                         /usr/local/bin/composer dump-autoload;\
                         chmod -R 777 ${destination_dir}/storage;\
                         chmod -R 777 ${destination_dir}/vendor;\
                         GET_COMMAND=\"ls -ld $destination_dir\";\
                         GETCOMMND_RESULT=\$(\$GET_COMMAND);\
                         OWNER=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=3);\
                         GROUP=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=4);\
                         echo ow is \$OWNER;\
                         echo gp is \$GROUP;\
                         chown -R \$OWNER:\$GROUP $destination_dir/*;\
                         rm -f $destination_dir/composer.json $destination_dir/composer.lock;\
"
  ;;
  "Manual")
      echo "Type is :$Type"
#    echo "Action Name is : $ActionName";
#    echo "Request Name is : $RequestName";
    echo "Artisan Command is : $ArtisanCommand";
    ssh -l $destination_user $destination_host \
                          -o PasswordAuthentication=no    \
                          -o StrictHostKeyChecking=no     \
                          -o UserKnownHostsFile=/dev/null \
                          -p 2225                         \
                          -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
                         "cd $destination_dir;\
                         bash /var/www/$currentScriptDir/localDeploy/git/git-submodule-composer-update.sh $destination_dir; \
                         $ArtisanCommand;\
                         chmod -R 777 ${destination_dir}/storage;\
                         chmod -R 777 ${destination_dir}/vendor;\
                         GET_COMMAND=\"ls -ld $destination_dir\";\
                         GETCOMMND_RESULT=\$(\$GET_COMMAND);\
                         OWNER=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=3);\
                         GROUP=\$(echo \$GETCOMMND_RESULT | cut --delimiter=' ' --fields=4);\
                         echo ow is \$OWNER;\
                         echo gp is \$GROUP;\
                         chown -R \$OWNER:\$GROUP $destination_dir/*;\
                         rm -f $destination_dir/composer.json $destination_dir/composer.lock;\
"
  ;;
  "Delete")
      echo "Type is :$Type"
#    echo "Action Name is : $ActionName";
#    echo "Request Name is : $RequestName";
#    echo "Artisan Command is : $ArtisanCommand";
    ssh -l $destination_user $destination_host \
                          -o PasswordAuthentication=no    \
                          -o StrictHostKeyChecking=no     \
                          -o UserKnownHostsFile=/dev/null \
                          -p 2225                         \
                          -i /var/jenkins_workspace/harrisdock/workspace/insecure_id_rsa    \
                         "cd $destination_dir;\
                          rm -rf $destination_dir/$FilePath;\
    "
  ;;
  *)
  exit
  ;;
esac
##################################################################################