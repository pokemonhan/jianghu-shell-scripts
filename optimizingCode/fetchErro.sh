#!/bin/sh
# cd /e/projects/jianghu_entertain;
# folder="/e/test"
# for file in $folder/*; do
#   echo "${file##*/} and full is $file"
# done

PROJ_DIR="/var/www/jianghu_entertain"
igDir1="$PROJ_DIR/bootstrap"
igDir2="$PROJ_DIR/jianghu_entertain_composer"
igDir3="$PROJ_DIR/phpcs-rule"
igDir4="$PROJ_DIR/public"
igDir5="$PROJ_DIR/resources"
igDir6="$PROJ_DIR/storage"
igDir7="$PROJ_DIR/tests"
igDir8="$PROJ_DIR/vendor"
igDir9="$PROJ_DIR/.git"
igDir10="$PROJ_DIR/.idea"

# input="b.txt"
# function execDirConfigFile()
# {
# 	while IFS= read -r line; do
# 		line=$(echo "$line" | tr -d '\r')
#     if [[ $line != *"#"* ]]; then
#     	excludeString+="-not \( -path $PROJ_DIR/$line -prune \) "
# 	fi
# 	done < $input
# }
# execDirConfigFile
# find $PROJ_DIR -type f

#create Commit Message
function execEachFile()
{
    # make newlines the only separator
    set -f
    IFS=$'\n'
    files=$(find $PROJ_DIR -not \( -path $igDir1 -prune \) -not \( -path $igDir2 -prune \) -not \( -path $igDir3 -prune \) -not \( -path $igDir4 -prune \) -not \( -path $igDir5 -prune \) -not \( -path $igDir6 -prune \) -not \( -path $igDir7 -prune \) -not \( -path $igDir8 -prune \) -not \( -path $igDir9 -prune \) -not \( -path $igDir10 -prune \) -name \*.*)
#    pids=()
    for file in $files
    do
     # echo "current Line is $file"
    analyzeFile $file
#    pids+=($!)
    done
    set +f; unset IFS

#    for pid in "${pids[@]}"; do
#      #
#      # Waiting on a specific PID makes the wait command return with the exit
#      # status of that process. Because of the 'set -e' setting, any exit status
#      # other than zero causes the current shell to terminate with that exit
#      # status as well.
#      #
#      wait "$pid"
#    done
    # disable globbing
}

function analyzeFile()
{
	# file=${1##*/}
	# echo "filename is $file"
	#original /e/projects/jianghu_entertain/.editorconfig
	#to get .editorconfig
	currentfilePath=$(echo "$1"| cut -d '/' -f5-)
	newfileNew="$(echo "$currentfilePath" | sed s:/:__:g)"
	echo "$newfileNew"
	# echo "$(realpath ${1} | sed s:/:__:g)"
	analyzResult=$(/var/www/jianghu_entertain/vendor/bin/phpcs --standard="/var/www/jianghu_entertain/phpcs-rule/phpcs.xml" "$1")
	EXIT_STATUS=$?
#  /var/www/jianghu_entertain/vendor/bin/phpcs --standard="/var/www/jianghu_entertain/phpcs-rule/phpcs.xml" "$1"
        echo "exist status is $EXIT_STATUS"
        if [ "$EXIT_STATUS" -eq "0" ]; then
          echo "\t\033[32mPHPCS Passed: $1\033[0m result"
        else
          echo "$analyzResult" >> /var/www/tmp/$newfileNew.log
          #Send Telegram Message to Specific Group
#          https://github.com/topkecleon/telegram-bot-bash
          cd /var/www/telegram-bot-bash;
          export BASHBOT_HOME="$(pwd)";
          source ./bashbot.sh source;
          send_file '-365299766' "/var/www/tmp/$newfileNew.log" ''
        fi
}

cd $PROJ_DIR
git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout develop/harris/original --
execEachFile

echo Press Enter...
read
