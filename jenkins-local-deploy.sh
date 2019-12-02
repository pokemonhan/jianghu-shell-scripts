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
case $BUILD_USER_FIRST_NAME in
   "Harris")
   destination_dir="$shareprj/harris/$tailPath"
      ;;
    "Alvin")
   destination_dir="$shareprj/alvinphp/$tailPath"
      ;;
    "taibo")
   destination_dir="$shareprj/taibophp/$tailPath"
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
    ssh -l $destination_user $destination_host \
                  -o PasswordAuthentication=no    \
                  -o StrictHostKeyChecking=no     \
                  -o UserKnownHostsFile=/dev/null \
                  -p 2225                         \
                  -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                 "cd $destination_dir;\
                 /usr/local/bin/composer install --no-interaction --no-progress --no-ansi --prefer-dist --optimize-autoloader;\
                  php artisan clear-compiled;\
                  php artisan cache:clear;\
                  php artisan route:cache;\
                  php artisan config:cache;\
                  chmod -R 777 ${destination_dir}/storage;\
                  chmod -R 777 ${destination_dir}/vendor;\
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
                  -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                 "cd $destination_dir;\
                 /usr/local/bin/composer update --no-interaction --no-progress --no-ansi;\
                  php artisan clear-compiled;\
                  php artisan config:cache;\
                  chmod -R 777 ${destination_dir}/storage;\
                  chmod -R 777 ${destination_dir}/vendor;\
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
                        -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                       "cd $destination_dir;\
                        php artisan clear-compiled;\
                        php artisan cache:clear;\
                        php artisan route:cache;\
                        php artisan config:cache;\
      "
  ;;
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
                      -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                     "cd $destination_dir;\
                     /usr/local/bin/composer dump-autoload;\
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
                          -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                         "cd $destination_dir;\
                         $ActionCommand;\
                         /usr/local/bin/composer dump-autoload;\
                          "
  ;;
  "Manual")
      echo "Type is :$Type"
#    echo "Action Name is : $ActionName";
#    echo "Request Name is : $RequestName";
#    echo "Artisan Command is : $ArtisanCommand";
    ssh -l $destination_user $destination_host \
                          -o PasswordAuthentication=no    \
                          -o StrictHostKeyChecking=no     \
                          -o UserKnownHostsFile=/dev/null \
                          -p 2225                         \
                          -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                         "cd $destination_dir;\
                         $ArtisanCommand;\
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
                          -i /var/jenkins_workspace/harrisdock/workspace7/insecure_id_rsa    \
                         "cd $destination_dir;\
                         rm -rf $destination_dir/$FilePath;\
    "
  ;;
  *)
  exit
  ;;
esac
##################################################################################