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

function echoCommitMessage()
{
#        echo here is in merge "$1";
#    7173111c6b3aace21a723bdbc661f8ff04faa9aeê:tada: 打tag 远程更新时本地需要从目前最低版本打 tag bug 修复êFri Jan 10 10:07:19 2020 +0800êHarrisê
    set -f; IFS='ê'
	  set -- $1
	# every strange character should use double place
    normal 	echo "1 is $1, 2 is $2,3 is $3,4 is $4,5 is $5,6 is $6,7 is $7,8 is $8"
#    echo "$i:来自分支=》$branchName"
    echo " 信息=》$2"
    echo " 提交者=》$4"
    echo " 日期=》$3"
    set +f; unset IFS
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
          log=$(git log -n 1 --pretty='format:%Hê%sê%adê%anê' -- "$currentfilePath")
          msgCaption="$currentfilePath"
          msgCaption+=$(echoCommitMessage $log)
#          echo "$msgCaption"
          #Send Telegram Message to Specific Group
#          https://github.com/topkecleon/telegram-bot-bash
#          https://github.com/rahiel/telegram-send
          telegram-send --file "/var/www/tmp/$newfileNew.log" --caption "$currentfilePath"
        fi
}

cd $PROJ_DIR
git -c credential.helper= -c core.quotepath=false -c log.showSignature=false checkout develop/harris/original --
execEachFile
