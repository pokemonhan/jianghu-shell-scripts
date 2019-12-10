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

#echo "RUN pre-receive hook (https://github.com/ezweb/pre-receive-hook)"



function cleanup()
{
  echo "tmpdir is $TMP_DIR";
	if [ -d "$TMP_DIR" ]
	then
		rm -rf "$TMP_DIR"
	fi
}


function tmpdir()
{
    projDir='test'
    if [ -z "$TMP_DIR" ]
    then
        TMP_DIR=$( mktemp -d /var/www/tmp/pre-receive-hook-XXXXX )
        cp -rf /var/www/$projDir $TMP_DIR
    fi
}


function create_changed_file()
{
    projDir='test'
    file="$1"
    short_file_name=$( basename $file )
    tmpdir
    git show $newrev:$file >$TMP_DIR/$projDir/$short_file_name
    echo "$TMP_DIR/$projDir/$short_file_name"
}


function error()
{
    echo ""
    echo -e "\033[31m ================================================================ \033[0m"
    echo -e "\033[31m =                         错误  !!!                           = \033[0m"
    echo -e "\033[31m ================================================================ \033[0m"
    echo ""
    echo -e "\033[31m ERROR: $@ \033[0m"
    echo ""

    cleanup
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


function validate_crontab()
{
    local CHKCRONTAB=/usr/local/chkcrontab/chkcrontabb
    # check tool presence...
    if [ ! -x $CHKCRONTAB ]
    then
        if [ -x $TMPTOOLS/chkcrontab/chkcrontab ]
        then
            CHKCRONTAB=$TMPTOOLS/chkcrontab/chkcrontab
            # ensure up-to-date
            debug "ensure chkcrontab is up to date in $TMPTOOLS/chkcrontab"
            # in a sub-shell
            (
                cd $TMPTOOLS/chkcrontab
                unset GIT_DIR
                git pull -q origin
            )
        else
            echo "Install tool chkcrontab ..."
            if git clone -q $CHKCRONTAB_GIT $TMPTOOLS/chkcrontab
            then
                CHKCRONTAB=$TMPTOOLS/chkcrontab/chkcrontab
            fi
        fi
    fi

    if [ ! -x $CHKCRONTAB ]
    then
        echo "(warning: crontab linter does not exists. Check skipped.)"
        return 0
    fi

    local changed_file=$( create_changed_file "$1" )
    if ! $CHKCRONTAB $CHKCRONTAB_ARGS $changed_file
    then
        if ! $CHKCRONTAB $CHKCRONTAB_ARGS -u $changed_file
        then
            error "$filename doesn't pass crontab check."
        fi
    fi
}


function validate_php()
{
  currentfile="$1"
  currentDir="$2"
  TMP_DIR="$3"
  destination_dir=$currentDir
  echo "currentfile is $currentfile and currentDir is $currentDir and tmpdir is $TMP_DIR and destination_dir is $destination_dir"
  destination_user="root"
  destination_host="172.19.0.1"
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
        projDir=$currentDir
        RULESET="$projDir/phpcs.xml"
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
          cleanup
          echo "\t\033[32mPHPCS Passed: $filename\033[0m result"
        else
          cleanup
          error " \t\033[41mPHPCS Failed: $filename\033[0m"
        fi
    else
        echo "(php is not available, check skipped.)"
        cleanup
        return 0
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


function validate_script()
{
    local checker=
    local checker_opts=
    local changed_file=$( create_changed_file "$2" )
    if [ "$1" = "pl" ]
    then
        checker=perl
        checker_opts="-c"
    elif [ "$1" = "py" ]
    then
        checker=python3
        checker_opts="-m py_compile"
    fi

    if ! which $checker >/dev/null
    then
        echo "($checker is not available, check skipped.)"
        return 0
    fi

    if ! eval "$checker $checker_opts \"$changed_file\""
    then
        error "$filename doesn't pass $checker syntax check."
    fi
}


function get_extension()
{
    file="$( basename $1 )"
    echo ${file##*.}
}


trap "cleanup" INT QUIT TERM TSTP EXIT

# Run loop as soon as possible, to ensure this is this loop that will handle stdin
while read oldrev newrev ref
do
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
	  ############################################################
	  projDir='test'
	  TMP_DIR=$( mktemp -d /var/www/tmp/pre-receive-hook-XXXXX )
	  currentDir=$TMP_DIR/$projDir
	  echo commit is $commit;
	  echo "starting coppy the dir";
    cp -rf /var/www/$projDir $TMP_DIR
	  for filename in $( git diff --name-only $commit^..$commit )
		do
		    echo file name is $filename;
		    currentfile=$TMP_DIR/$projDir/$filename
        git show $newrev:$filename >$currentfile
        echo "current file is $currentfile"
		done
		#######
	  ###########################################################
		for filename in $( git diff --name-only $commit^..$commit )
		do
			# TODO: if not a file, continue...

      extension="$( get_extension $filename )"
			if grep -F /crontab <<< "$filename"
			then
                validate_crontab $filename
            elif [ "$extension" = "php" ]
            then
               echo vd file name is $filename;
		           currentfile=$TMP_DIR/$projDir/$filename
		           echo "vd current file is $currentfile"
		           echo "ready to validate php"
                validate_php $currentfile $currentDir $TMP_DIR
            elif [ "$extension" = "pl" ] || [ "$extension" = "py" ]
            then
                validate_script $extension $filename
			fi
		done
	done
done

exit 0