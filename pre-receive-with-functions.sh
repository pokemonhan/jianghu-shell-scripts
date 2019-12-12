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
destination_host="172.19.0.1"
projDir='jianghu_entertain'

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
#  echo "before errorStatus is $errorStatus"
#  errorStatus=$((errorStatus+1))
#  echo "after errorStatus is $errorStatus"
#    (($errorStatus++))
#    echo "error status is $errorStatus"
    echo -e "\033[31m ================================================================ \033[0m"
    echo -e "\033[31m =                         错误  !!!                           = \033[0m"
    echo -e "\033[31m ================================================================ \033[0m"
    echo ""
    echo -e "\033[31m ERROR: $@ \033[0m"
    echo ""
    exit 3
}


#function warn()
#{
#    echo ""
#    echo -e "\033[1;31m\033[43m ================================================================ \033[0m"
#    echo -e "\033[1;31m\033[43m =                        WARNING !!!                           = \033[0m"
#    echo -e "\033[1;31m\033[43m ================================================================ \033[0m"
#    echo ""
#    echo -e "\033[1;31m\033[43m >>> $@ \033[0m"
#    echo ""
#}


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


#function validate_crontab()
#{
#    local CHKCRONTAB=/usr/local/chkcrontab/chkcrontabb
#    # check tool presence...
#    if [ ! -x $CHKCRONTAB ]
#    then
#        if [ -x $TMPTOOLS/chkcrontab/chkcrontab ]
#        then
#            CHKCRONTAB=$TMPTOOLS/chkcrontab/chkcrontab
#            # ensure up-to-date
#            debug "ensure chkcrontab is up to date in $TMPTOOLS/chkcrontab"
#            # in a sub-shell
#            (
#                cd $TMPTOOLS/chkcrontab
#                unset GIT_DIR
#                git pull -q origin
#            )
#        else
#            echo "Install tool chkcrontab ..."
#            if git clone -q $CHKCRONTAB_GIT $TMPTOOLS/chkcrontab
#            then
#                CHKCRONTAB=$TMPTOOLS/chkcrontab/chkcrontab
#            fi
#        fi
#    fi
#
#    if [ ! -x $CHKCRONTAB ]
#    then
#        echo "(warning: crontab linter does not exists. Check skipped.)"
#        return 0
#    fi
#
#    local changed_file=$( create_changed_file "$1" )
#    if ! $CHKCRONTAB $CHKCRONTAB_ARGS $changed_file
#    then
#        if ! $CHKCRONTAB $CHKCRONTAB_ARGS -u $changed_file
#        then
#            error "$filename doesn't pass crontab check."
#        fi
#    fi
#}


function validate_php()
{
  local currentfile="$1"
  local currentDir="$2"
  local TMP_DIR="$3"
  local destination_user="$4"
  local destination_host="$5"
  echo "currentfile is $currentfile and currentDir is $currentDir and tmpdir is $TMP_DIR"
  php=$(ssh -l $destination_user $destination_host \
        -o PasswordAuthentication=no    \
        -o StrictHostKeyChecking=no     \
        -o UserKnownHostsFile=/dev/null \
        -p 2225                         \
        -i /var/www/harrisdock/workspace7/insecure_id_rsa    \
       "/usr/bin/php");
    if [ -x $php ]
    then
        local changed_file="$1"
        echo $changed_file;
        cat $changed_file;
#        projDir=$(echo $changed_file | cut -d '/' -f 1-6)
        local projDir=$currentDir
        ################# [ phpcs checking ]######################
        RULESET="$projDir/phpcs.xml"
        if [ -d "$projDir" ]; then
             ssh -l $destination_user $destination_host \
        -o PasswordAuthentication=no    \
        -o StrictHostKeyChecking=no     \
        -o UserKnownHostsFile=/dev/null \
        -p 2225                         \
        -i /var/www/harrisdock/workspace7/insecure_id_rsa    \
       "cd $projDir/vendor/bin;\
./phpcs --standard=$RULESET $changed_file"
        EXIT_STATUS=$?
        echo "exist status is $EXIT_STATUS"
        if [ "$EXIT_STATUS" -eq "0" ]; then
          echo "\t\033[32mPHPCS Passed: $filename\033[0m result"
        else
#          cleanup $TMP_DIR
          error " \t\033[41mPHPCS Failed: $filename\033[0m"
        fi
        ######################[larastan checking ]##################################
        autoloadPath="$projDir/vendor/autoload.php"
        neonfile="$projDir/phpstan.neon"
        ssh -l $destination_user $destination_host \
        -o PasswordAuthentication=no    \
        -o StrictHostKeyChecking=no     \
        -o UserKnownHostsFile=/dev/null \
        -p 2225                         \
        -i /var/www/harrisdock/workspace7/insecure_id_rsa    \
       "cd $projDir;\
       php artisan code:analyse --error-format=table --memory-limit=1G -a $autoloadPath -c $neonfile --paths=$changed_file;"
       STAN_STATUS=$?
        echo "STAN status is $STAN_STATUS"
          if [ "$STAN_STATUS" -eq "0" ]; then
            echo 'passed'
          else
            echo "$STAN_STATUS"
#            cleanup $TMP_DIR
            error "Code Quality Test Failed"
          fi
        else
          error "folder already remove due to error"
        fi
        ########################################################
    else
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


#function validate_script()
#{
#    local checker=
#    local checker_opts=
#    local changed_file=$( create_changed_file "$2" )
#    if [ "$1" = "pl" ]
#    then
#        checker=perl
#        checker_opts="-c"
#    elif [ "$1" = "py" ]
#    then
#        checker=python3
#        checker_opts="-m py_compile"
#    fi
#
#    if ! which $checker >/dev/null
#    then
#        echo "($checker is not available, check skipped.)"
#        return 0
#    fi
#
#    if ! eval "$checker $checker_opts \"$changed_file\""
#    then
#        error "$filename doesn't pass $checker syntax check."
#    fi
#}


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
        if [ ! -f "$currentfile" ]; then
             touch "$currentfile";
            echo "does not exist so created $currentfile"
        fi
        git show $newrev:$filename > "$currentfile"
        echo "current file is $currentfile"
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

#trap "cleanup" INT QUIT TERM TSTP EXIT

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
  # shellcheck disable=SC2095
  ssh -l $destination_user $destination_host \
      -o PasswordAuthentication=no    \
      -o StrictHostKeyChecking=no     \
      -o UserKnownHostsFile=/dev/null \
      -p 2225                         \
      -i /var/www/harrisdock/workspace7/insecure_id_rsa    \
     "cd $currentDir;\
     git reset --hard;\
     git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout -b $current_branch origin/$current_branch --;\
     git reset --hard;\
     git fetch --all;\
     git pull origin $current_branch;
     git branch;\
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
      # 'set -e' tells the shell to exit if any of the foreground command fails,
    # i.e. exits with a non-zero status.
#    set -eu
    # Initialize array of PIDs for the background jobs that we're about to launch.
    pids=()
		for filename in $( git diff --name-only $commit^..$commit )
		do
		 ################################[parallel analyzing files ]###################################
		 fileAnalysis "$filename" "$currentDir" "$TMP_DIR" "$destination_user" "$destination_host" &
		 # Add the PID of this background job to the array.
     pids+=($!)
		 #############################################################################################
		done
		####################################################
#		wait_and_get_exit_codes "${pids[@]}"
#		# it seems it does not work well if using echo for function return value, and calling inside $() (is a subprocess spawned?)
#    function wait_and_get_exit_codes() {
#        children=("$@")
#        EXIT_CODE=0
#        for job in "${children[@]}"; do
#           echo "PID => ${job}"
#           CODE=0;
#           wait ${job} || CODE=$?
#           if [[ "${CODE}" != "0" ]]; then
#               echo "At least one test failed with exit code => ${CODE}" ;
#               EXIT_CODE=1;
#           fi
#       done
##       cleanup $TMP_DIR
#    }
#    echo "EXIT_CODE => $EXIT_CODE"
#    exit "$EXIT_CODE"
		####################################################
		# Wait for each specific process to terminate.
    # Instead of this loop, a single call to 'wait' would wait for all the jobs
    # to terminate, but it would not give us their exit status.
    #
#    pcounter=0
#    errorFinalStatus=0
    for pid in "${pids[@]}"; do
      echo "pid is $pid before wait"
      echo "pids is $pids before wait"
      echo "last is $lastpid before wait"
      #
      # Waiting on a specific PID makes the wait command return with the exit
      # status of that process. Because of the 'set -e' setting, any exit status
      # other than zero causes the current shell to terminate with that exit
      # status as well.
      #
#      ((pcounter++))
      wait "$pid"
      exit_status=$?
      lastpid=$!
      min=0
      max=$(( ${#pids[@]} -1 ))
      x="${pids[$min]}"
      y="${pids[$max]}"
      echo "min is $x"
      echo "max is $y"
#      echo "pid is $pid after wait"
      echo "pids is $pids after wait"
      echo "last is $lastpid after wait"
      echo "exit status: $exit_status"
      if [ "$exit_status" -gt 0 ]; then
#        errorFinalStatus=$((errorFinalStatus+$exit_status))
        echo "current exist status is $exit_status at gt 0"
        cleanup $TMP_DIR
        exit 1
#      elif [ "$exit_status" -eq "0" ]; then
#        if [ ! -z "$lastpid" ] && [ "$y" -eq $((lastpid-1)) ]; then
#          echo "pids is $pids";
#          echo "last is $lastpid"
#          echo "current exist status is $exit_status at elif"
#          cleanup $TMP_DIR
##          exit $exit_status
##        else
##          continue
#        fi
      fi
#      echo "final exit status: $errorFinalStatus"
#      exit $errorFinalStatus
    done
	done
	############################################
done
cleanup $TMP_DIR
#exit 1
exit 0
