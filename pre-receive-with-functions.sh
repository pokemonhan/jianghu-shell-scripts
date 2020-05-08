#!/bin/bash
# 1/ ensure I'm up to date, but do not fail if not
# 2/ check tools presence
# 3/ loop on files, and run lint tool on them
#
# Supported:
# - crontabs
# - PHP (lint + phpcs)
# - Perl
# - Python



# php coding standards
PHPCS_STANDARD="PSR2"
PHPCS_REPORT="diff"
PHPCS_ENCODING="utf-8"

CHKCRONTAB_GIT="https://github.com/gregorg/chkcrontab"
CHKCRONTAB_ARGS="-w ejabberd -w ezwww -w www-data -w nobody"
NULL_SHA1="0000000000000000000000000000000000000000" # 40 0's
UPTODATE_RUNNED=0
DEBUG=0
TMP_DIR=
TMPTOOLS=/tmp/check_tools

errorStatus=0
destination_user="root"
destination_host=`ip route show 0.0.0.0/0 dev eth0 | cut -d\  -f3`
projDir='jianghu_entertain'
#get current script directory dynamically
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $dir;
#currentScriptDir="${dir##*/}";
currentScriptDir="shell-scripts";

#echo "RUN pre-receive hook (https://github.com/ezweb/pre-receive-hook)"

#	   OWNER=`ls -ld $TMP_DIR | cut --delimiter=" " --fields="3"`
#     GROUP=`ls -ld $TMP_DIR | cut --delimiter=" " --fields="4"`
#     echo $OWNER:$GROUP
#     chown -R $OWNER:$GROUP $TMP_DIR/*;
#     chmod -R 777 $TMP_DIR;

function cleanup()
{
  TMP_DIR="$1";
  echo "tmpdir is $TMP_DIR";
	if [ -d "$TMP_DIR" ]
	then
		 rm -rf "$TMP_DIR"
	fi
}


#function tmpdir()
#{
#    projDir='jianghu_entertain'
#    if [ -z "$TMP_DIR" ]
#    then
#        TMP_DIR=$( mktemp -d /var/www/tmp/pre-receive-hook-XXXXX )
#        cp -rf /var/www/$projDir $TMP_DIR
#    fi
#}
#
#
#function create_changed_file()
#{
#    local projDir='jianghu_entertain'
#    file="$1"
#    short_file_name=$( basename $file )
#    tmpdir
#    git show $newrev:$file >$TMP_DIR/$projDir/$short_file_name
#    echo "$TMP_DIR/$projDir/$short_file_name"
#}


function error()
{
#    (($errorStatus++))
    echo "error status is $errorStatus"
    echo -e "\033[31m ================================================================ \033[0m"
    echo -e "\033[31m =                         错误  !!!                           = \033[0m"
    echo -e "\033[31m ================================================================ \033[0m"
    echo ""
    echo -e "\033[31m ERROR: $@ \033[0m"
    echo ""
#    cleanup
    exit 3
}


function warn()
{
    echo ""
    echo -e "\033[1;31m\033[43m ================================================================ \033[0m"
    echo -e "\033[1;31m\033[43m =                        WARNING !!!                           = \033[0m"
    echo -e "\033[1;31m\033[43m ================================================================ \033[0m"
    echo ""
    echo -e "\033[1;31m\033[43m >>> $@ \033[0m"
    echo ""
}


function debug()
{
    if [ $DEBUG -gt 0 ]
    then
        echo "(debug: $@)"
    fi
}

function checkError()
{
  echo "now errorStatus is $errorStatus";
    if [ $errorStatus -gt 0 ]
    then
      echo "error has occured"
        exist 1;
    fi
}


function validate_php()
{
  local changed_file="$1"
  local projDir="$2"
  local TMP_DIR="$3"
  local destination_user="$4"
  local destination_host="$5"
  echo "currentfile is $changed_file and currentDir is $projDir and tmpdir is $TMP_DIR"
  php=$(ssh -l $destination_user $destination_host \
        -o PasswordAuthentication=no    \
        -o StrictHostKeyChecking=no     \
        -o UserKnownHostsFile=/dev/null \
        -p 2225                         \
        -i /var/www/harrisdock/workspace/insecure_id_rsa    \
       "/usr/bin/php");
    if [ -x $php ]
    then
        echo $changed_file;
        cat $changed_file;
#        projDir=$(echo $changed_file | cut -d '/' -f 1-6)
        if [ -d "$projDir" ]; then
        ################# [ phpcs checking & larastan checking]######################
        validatePhpcs "$destination_user" "$destination_host" "$projDir" "$changed_file" "$filename" "$TMP_DIR" &
        validatePHPStan "$destination_user" "$destination_host" "$projDir" "$changed_file" "$TMP_DIR"
        ########################################################
        else
          echo "dir was clear due to error"
          exit 1;
        fi
    else
        cleanup $TMP_DIR
        error "(php is not available, check skipped.)"
    fi

    #PHPCS=$TMPTOOLS/phpcs.phar
    #if [ ! -e $PHPCS ]
    #then
    #    debug "Fetch phpcs ..."
    #    curl -so $PHPCS -L https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
    #fi
    #if [ -e $PHPCS ]
    #then
    #    debug "run phpcs ..."
    #    if ! php $PHPCS -n --colors --encoding=${PHPCS_ENCODING} --report=${PHPCS_REPORT} --standard=${PHPCS_STANDARD} $changed_file
    #    then
    #        # still some works to do, do not report an error, yet...
    #        warn "PHPCS check doesn't pass."
    #    fi
    #else
    #    echo "(phpCS is not available, check skipped.)"
    #fi
}

function validatePhpcs() {
  local destination_user="$1"
  local destination_host="$2"
  local projDir="$3"
  local changed_file="$4"
  local filename="$5"
  local TMP_DIR="$6"
  if [ -f "$changed_file" ]; then
    ################# [ phpcs checking ]######################
  ###phpcs should check under without swoole loader because depreacated rule not compatibality with it####
        RULESET="$projDir/phpcs-rule/phpcs.xml"
        ssh -l "$destination_user" "$destination_host" \
        -o PasswordAuthentication=no    \
        -o StrictHostKeyChecking=no     \
        -o UserKnownHostsFile=/dev/null \
        -p 2226                         \
        -i /var/www/harrisdock/workspace/insecure_id_rsa    \
       "bash /var/www/$currentScriptDir/hookexec/phpcs.sh $projDir $RULESET $changed_file;"
        EXIT_STATUS=$?
        echo "exist status is $EXIT_STATUS"
        if [ "$EXIT_STATUS" -eq "0" ]; then
          echo "\t\033[32mPHPCS Passed: $filename\033[0m result"
        else
          cleanup $TMP_DIR
          error " \t\033[41mPHPCS Failed: $filename\033[0m"
        fi
  fi
}

function validatePHPStan() {
  local destination_user="$1"
  local destination_host="$2"
  local projDir="$3"
  local changed_file="$4"
  local TMP_DIR="$5"
  if [ -f "$changed_file" ]; then
    ################# [ php-stan checking ]######################
    autoloadPath="$projDir/vendor/autoload.php"
    neonfile="$projDir/phpcs-rule/phpstan.neon"
    ssh -l "$destination_user" "$destination_host" \
    -o PasswordAuthentication=no    \
    -o StrictHostKeyChecking=no     \
    -o UserKnownHostsFile=/dev/null \
    -p 2225                         \
    -i /var/www/harrisdock/workspace/insecure_id_rsa    \
   "bash /var/www/$currentScriptDir/hookexec/phpstan.sh $projDir $neonfile $autoloadPath $changed_file;"
   STAN_STATUS=$?
    echo "STAN status is $STAN_STATUS"
      if [ "$STAN_STATUS" -eq "0" ]; then
        echo 'passed'
      else
        echo "$STAN_STATUS"
        cleanup $TMP_DIR
        error "Code Quality Test Failed"
      fi
    fi
}


function get_extension()
{
    file="$( basename $1 )"
    echo ${file##*.}
}

function writefile() {
  local newrev="$1"
  local filename="$2"
  local currentDir="$3"
  local currentfile="$currentDir/$filename"
    #		    echo file name is $filename;
		    mkdir -m 777 -p $(dirname "$currentfile")
		    newFile=$(git show $newrev:$filename)
		    if [ -z "$newFile" ]; then
		        echo "$currentfile empty"
		      if [ -f "$currentfile" ]; then
             rm -f "$currentfile"
          fi
		    else
		      if [ ! -f "$currentfile" ]; then
             touch "$currentfile";
            echo "does not exist so created $currentfile"
          fi
          git show $newrev:$filename > "$currentfile"
  #        rm -f $currentfile
  #        mv "$currentfile.txt" "$currentfile"
          echo "current file is $currentfile"
		    fi
          if [ ! -f "${currentDir}/composer.json" ]; then
            cp ${currentDir}/jianghu_entertain_composer/composer.json ${currentDir}/composer.json;
          fi
#        cat $currentfile;
}

function fileAnalysis() {
  local filename="$1"
  local currentDir="$2"
  local TMP_DIR="$3"
  local destination_user="$4"
  local destination_host="$5"

    # TODO: if not a file, continue...

      extension="$( get_extension $filename )"
#			if grep -F /crontab <<< "$filename"
#			    then
#                validate_crontab $filename
#            elif [ "$extension" = "php" ]
            if [ "$extension" = "php" ]
            then
#               echo vd file name is $filename;
		           local currentfile=$currentDir/$filename
#		           echo "vd current file is $currentfile"
		           echo "ready to validate php"
                validate_php "$currentfile" "$currentDir" "$TMP_DIR" "$destination_user" "$destination_host"
#            elif [ "$extension" = "pl" ] || [ "$extension" = "py" ]
#            then
#                validate_script $extension $filename
			      fi
}


trap "cleanup" INT QUIT TERM TSTP EXIT

# Run loop as soon as possible, to ensure this is this loop that will handle stdin
while read oldrev newrev ref
do
  ####################[Checkout current Branch]########################################
  TMP_DIR=$( mktemp -d /var/www/tmp/pre-receive-hook-XXXXX )
  currentDir=$TMP_DIR/$projDir
  echo commit is $commit;
  echo "starting copy /var/www/$projDir to $TMP_DIR";
  cp -rf /var/www/$projDir $TMP_DIR
  echo "$ref : $oldrev ~ $newrev"
  current_branch=$(echo $ref | cut -d '/' -f 3-)
  echo "current_branch name is $current_branch"
  if [ $oldrev != '0000000000000000000000000000000000000000' ]; then
      # shellcheck disable=SC2095
  ssh -l $destination_user $destination_host \
      -o PasswordAuthentication=no    \
      -o StrictHostKeyChecking=no     \
      -o UserKnownHostsFile=/dev/null \
      -p 2225                         \
      -i /var/www/harrisdock/workspace/insecure_id_rsa    \
     "cd $currentDir;\
     git reset --hard;\
     git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout -b $current_branch origin/$current_branch --;\
     git reset --hard;\
     git fetch --all;\
     git pull origin $current_branch;\
     git branch;\
     chmod -R 777 $currentDir;\
     cat > ${currentDir}/.gitmodules <<EOL
[submodule \"phpcs-rule\"]
    path = phpcs-rule
    url = ssh://git@${destination_host}:2289/php/phpcs-rule.git
[submodule \"jianghu_entertain_composer\"]
	path = jianghu_entertain_composer
	url = ssh://git@${destination_host}:2289/php/jianghu_entertain_composer.git
EOL
        chmod 777 ${currentDir}/.gitmodules;\
        if [[ ! -e ${currentDir}/phpcs-rule ]]; then \
            git submodule add -f ssh://git@${destination_host}:2289/php/phpcs-rule.git phpcs-rule;\
        fi;\
        if [[ ! -e ${currentDir}/jianghu_entertain_composer ]]; then \
            git submodule add -f ssh://git@${destination_host}:2289/php/jianghu_entertain_composer.git jianghu_entertain_composer;\
        fi;\
        git submodule init;\
        git submodule sync;\
        cd ${currentDir}/phpcs-rule;\
        git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout master --;\
        git -c credential.helper= -c core.quotepath=false -c log.showSignature=false fetch origin --progress --prune;\
        git reset --hard;\
        git fetch --all;\
        git pull origin master;\
        chmod -R 777 $currentDir;\
     "
  ###########################################################
	# in a sub-shell ...

	invalids=0
    test -d $TMPTOOLS || mkdir -p $TMPTOOLS

    # ugly hook that works in this specific case...
    if [ "$oldrev" = "$NULL_SHA1" ]
    then
        oldrev="$newrev^"
    fi
	for commit in $( git rev-list ${oldrev}..${newrev} )
	do
	  for filename in $( git diff --name-only $commit^..$commit )
		do
		  ##############[parallel writing files ]#############
		  writefile "$newrev" "$filename" "$currentDir" &
		  ####################################################
		done
	done
	#############################################
	for commit in $( git rev-list ${oldrev}..${newrev} )
	do
		for filename in $( git diff --name-only $commit^..$commit )
		do
		 ################################[parallel analyzing files ]###################################
		 fileAnalysis "$filename" "$currentDir" "$TMP_DIR" "$destination_user" "$destination_host"
		 #############################################################################################
		done
	done
	############################################
  fi
done
cleanup $TMP_DIR
exit 0
