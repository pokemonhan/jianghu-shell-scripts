#!/bin/sh
syncDirectory="/var/www/tmp/syncDir";
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo $dir;
#currentScriptDir="${dir##*/}";
input="$dir/syncPrjs.txt"

function gitParamRetrieve()
{
    local ProjectName=$(echo "$1"| cut -d ' ' -f1)
    local LocalGitlab=$(echo "$1"| cut -d ' ' -f2)
    local RMGitlab=$(echo "$1"| cut -d ' ' -f3)
    local GitUserName=$(echo "$1"| cut -d ' ' -f4)
    local GitUserEmail=$(echo "$1"| cut -d ' ' -f5)
    local GitUserName2=$(echo "$1"| cut -d ' ' -f6)
    local GitUserEmail2=$(echo "$1"| cut -d ' ' -f7)
    local pushable=$(echo "$1"| cut -d ' ' -f8)
#	set -f; IFS=' '
#	set -- $1
#	 echo "ProjectName is $ProjectName,LocalGitlab is $LocalGitlab,RMGitlab is $RMGitlab"
	gitSyncDirectory "$ProjectName" "$LocalGitlab" "$RMGitlab" "$GitUserName" "$GitUserEmail" "$GitUserName2" "$GitUserEmail2" "$pushable"
#	set +f; unset IFS
}

function gitSyncDirectory()
{
#    set +f; unset IFS
	local ProjectName="$1"
	local LocalGitlab="$2"
	local RMGitlab="$3"
	local GitUserName="$4"
  local GitUserEmail="$5"
  local GitUserName2="$6"
  local GitUserEmail2="$7"
  local pushable="$8"

	if [ ! -d "$syncDirectory/$ProjectName" ]
	then
		 mkdir -m 777 -p "$syncDirectory/$ProjectName"
#		 mkdir -p "$syncDirectory/$ProjectName"
		 output=$(git clone "$LocalGitlab" "$syncDirectory/$ProjectName")
#		 echo $output
	fi
	cd "$syncDirectory/$ProjectName"
	chmod -R 777 "$syncDirectory/$ProjectName"
	checkandSetUrl "$ProjectName" "$LocalGitlab" "$RMGitlab" "$GitUserName" "$GitUserEmail" "$GitUserName2" "$GitUserEmail2" "$pushable"
}

function checkandSetUrl()
{
    local ProjectName="$1"
    local LocalGitlab="$2"
    local RMGitlab="$3"
    local GitUserName="$4"
    local GitUserEmail="$5"
    local GitUserName2="$6"
    local GitUserEmail2="$7"
    local pushable="$8"

	  git config --global user.name server
    git config --global user.email server@jianghu.com
    git config core.fileMode false
    gitRMURLDetail=$(git remote -v)
#    echo "before is $gitRMURLDetail"
#####Handling for Second Url [remote url] #############
	git remote set-url origin "$RMGitlab"
	git config user.name "$GitUserName2"
  git config user.email "$GitUserEmail2"
	gitRMURLDetail=$(git remote -v)
#    echo "After is $gitRMURLDetail"
#####Handling for First Url [remote url] #############
	pushOrPullAction "$ProjectName" "$LocalGitlab" "$pushable"
	git remote set-url origin "$LocalGitlab"
	git config user.name "$GitUserName"
  git config user.email "$GitUserEmail"
}

function pushOrPullAction()
{
  local ProjectName="$1"
  local LocalGitlab="$2"
  local pushable="$3"
  #项目同步发版通知
  local tg_chat_group_id='-1001457674977';
   remoteUpdate=$(git remote -v update)
#	 echo $remoteUpdate
#    UPSTREAM=${1:-'@{u}'}
    local UPSTREAM='@{u}'
#    echo "upstream is $UPSTREAM"
    local LOCAL=$(git rev-parse @)
#    echo "LOCAL is $LOCAL"
    local REMOTE=$(git rev-parse "$UPSTREAM")
#    echo "REMOTE is $REMOTE"
    local BASE=$(git merge-base @ "$UPSTREAM")
#    echo "BASE is $BASE"
	if [[ $LOCAL == $REMOTE ]]; then
	     upd="up-to-date"
#	    echo "Up-to-date"
	elif [[ $LOCAL == $BASE ]]; then
	    echo "Need to pull"
#	    pulling=$(git -c credential.helper= -c core.quotepath=false -c log.showSignature=false fetch origin --recurse-submodules=no --progress --prune)
      pulling=$(git pull)
	    echo $pulling
#	    cd /var/www/telegram-bot-bash;
#      export BASHBOT_HOME="$(pwd)";
      echo "exported"
      me=$(whoami)
      echo "me is $me"
#      ./bashbot.sh init
#      source ./bashbot.sh source;
      echo "sourced"
      startEmoji="🤩";
      telegrammsg="$startEmoji [ 项目 $ProjectName 已从外网同步到本地gitlab ]$startEmoji\n\n";
      echo "msg is $telegrammsg"
#      send_message "$tg_chat_group_id" "$telegrammsg";
      git remote set-url origin "$LocalGitlab"
      pushing=$(git push)
#	  pushing=$(git -c credential.helper= -c core.quotepath=false -c log.showSignature=false push --progress --porcelain origin refs/heads/master:master)
	  echo $pushing
	elif [[ $REMOTE == $BASE ]]; then
	    echo "Need to push"
	    if [ "$pushable" -ne "0" ]; then
          echo "now ready to push to $LocalGitlab"
          git remote set-url origin "$LocalGitlab"
          pushing=$(git push)
          echo $pushing
      fi
	else
	    echo "Diverged"
	fi
}

while IFS= read -r line; do
    if [[ $line != *"#"* ]]; then
    	gitParamRetrieve "$line"
	fi
done < $input

scp -i /var/www/server/jianghu-malaysia.pem -r /var/www/jianghu_entertain/storage/statics root@47.254.235.19:/var/www/jianghu_entertain/storage/statics