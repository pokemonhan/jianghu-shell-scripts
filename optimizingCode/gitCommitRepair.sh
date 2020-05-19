#!/bin/sh
# cd /e/projects/jianghu_entertain;
# folder="/e/test"
# for file in $folder/*; do
#   echo "${file##*/} and full is $file"
# done

toCommitDir="/var/www/jianghu_entertain"
cd $toCommitDir

#create Commit Message
function execEachFile()
{
    # make newlines the only separator
    set -f
    IFS=$'\n'
    files=$(git status)
#    echo "current Tag is $listsTag"
    i=0
    for file in $files
    do
     # echo "current Line is $file"
	    if [[ $file == *"modified:"* ]]; then
	    	handleFiles $file
	    fi
    done
    set +f; unset IFS
    # disable globbing
}

function handleFiles() {
  handlefilePath=$(echo "$1"| cut -d ' ' -f2-)
	handlefilePath="$(echo -e "${handlefilePath}" | sed -e 's/^[[:space:]]*//')"
	#	echo "current is $currentfilePath"
	file=${1##*/}
#	echo "filename is $file"
	handlefilePath=$toCommitDir/$handlefilePath
	echo "full path is $handlefilePath"
	analyzeFile $handlefilePath
}

function analyzeFile()
{
  currentfilePath=$(echo "$1"| cut -d '/' -f5-)
	echo "currentfilePath is $currentfilePath"
	analyzResult=$(/var/www/jianghu_entertain/vendor/bin/phpcs --standard="/var/www/jianghu_entertain/phpcs-rule/phpcs.xml" "$currentfilePath")
	EXIT_STATUS=$?
        echo "exist status is $EXIT_STATUS"
        if [ "$i" -gt "0" ] && [ "$EXIT_STATUS" -ne "0" ] ; then
            i=0
          #second time enter into same function it should be send message
          sendFailFile "$currentfilePath"
        elif [ "$EXIT_STATUS" -eq "0" ]; then
            i=0
            #######################[execute PHPSTAN ]###########################
            projectfolder='/var/www/jianghu_entertain'
            neonfile="$projectfolder/phpcs-rule/phpstan.neon"
            autoloadPath="$projectfolder/vendor/autoload.php"
            # echo "$(realpath ${1} | sed s:/:__:g)"
            echo "starting Stan"
            analyzResult=$("$projectfolder"/vendor/bin/phpstan analyse -c "$neonfile" -a "$autoloadPath" "$currentfilePath" --error-format=table --memory-limit=1G)
            STAN_STATUS=$?
            echo "STAN status is $STAN_STATUS"
              if [ "$STAN_STATUS" -eq "0" ]; then
                echo "\t\033[32mPHPCS and PHPSTAN Passed: $currentfilePath\033[0m result"
              else
                echo "$STAN_STATUS"
                echo "Code Quality Test Failed"
                sendFailFile "$currentfilePath"
              fi
            ##################################################################
        else
            repairFile "$currentfilePath"
        fi
}

function repairFile() {
    RepairResult=$(/var/www/jianghu_entertain/vendor/bin/phpcbf --standard=/var/www/jianghu_entertain/phpcs-rule/phpcs.xml "$1")
    echo "$RepairResult"
    ((i++))
    analyzeFile "$1"
}

function sendFailFile() {
    #original /e/projects/jianghu_entertain/.editorconfig
    #to get .editorconfig
    currentfilePath="$1"
    newfileNew="$(echo "$currentfilePath" | sed s:/:__:g)"
    echo "$analyzResult" >> /var/www/tmp/commit_$newfileNew.log
    log=$(git log -n 1 --pretty='format:%Hê%sê%adê%anê' -- "$currentfilePath")
#    msgCaption="$currentfilePath"
#    msgCaption+=$(echoCommitMessage $log)
#          echo "$msgCaption"
    #Send Telegram Message to Specific Group
#          https://github.com/topkecleon/telegram-bot-bash
#          https://github.com/rahiel/telegram-send
#    telegram-send --file "/var/www/tmp/$newfileNew.log" --caption "$currentfilePath"
}

execEachFile
