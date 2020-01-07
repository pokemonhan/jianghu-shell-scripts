#!/bin/sh
destination_dir="$1"
tg_chat_group_id="$2"
cd "$destination_dir"
previousTag="$(git describe --abbrev=0)"
#Increment Function to string with pre zero and integer
function incnumstr()
{
  if [ $1 -lt 0 ] ; then
    set -- $(incnumstr ${1#-} $((- $2)))
    [ $1 -le 0 ] && printf "%s" ${1#-}  \
                 || printf "%s" -$1
    return
  fi
  set -- ${1#-} $2 # strip leading minus from zero
  [ $1 -eq 0 ] && printf "%s%0.*d" "$3" ${#1} $2 \
               || printf "%s%0.*d" "$3" ${#1} $(( ${1#${1%%[1-9]*}} + $2 ))
}

#Create Version Number
function createVersionNumber()
{
	versionPrefix="V-JH-$(date +"%Y%m%d")"
	set -f; IFS='-'
	set -- $1
	if [[ -z $1 ]]; then
	  versionNumber="$versionPrefix$(printf "%03d" 1)-$(printf "%03d" 1)"
	  echo "$versionNumber"
	elif [[ "$1" = "jianghu" ]]; then
		versionPrefix="$versionPrefix$(printf "%03d" 1)"
		pv=$2
		((pv++))
		versionNumber="$versionPrefix-$pv"
		echo "$versionNumber"
	else
		dVno=$3
		prefiousPrefix="V-JH-${dVno:0:8}"
		#同样一天的版本就累加不是同样就得从001开始
		if [ "$prefiousPrefix" = "$versionPrefix" ]; then
		    dayVno="${dVno:8:3}"
        dayVno="$(incnumstr $dayVno 1)"
    else
        dayVno="$(printf "%03d" 1)"
		fi
		pv="$(incnumstr $4 1)"
		versionNumber="$versionPrefix${dayVno}-$pv"
		echo "$versionNumber"
	fi
	set +f; unset IFS
}

#echo Commit Message
function echoCommitMessage()
{
    # b27da964db4b3e1534d35866f746055378aef2bd (master),Merge branch 'feature/taibo/h5-recharge-order-offline',Tue Jan 7 15:16:32 2020,Harris,<harrisdt15f@gmail.com>
    # 01f6db6f894f18f89fc19b91747783ffd0bb6f8a (feature/taibo/h5-recharge-order-offline),:sparkles: write bb,Tue Jan 7 12:38:56 2020,Harris,<harrisdt15f@gmail.com>
    # 356ab5f64176e7b9aa5cd99d0f7c148ca12a975f (feature/taibo/h5-recharge-order-offline~1),:sparkles: write aa,Tue Jan 7 12:38:39 2020,Harris,<harrisdt15f@gmail.com>
    set -f; IFS=','
	set -- $1
    branchName=$(echo "$1"| cut -d ' ' -f2)
    if [[ $2 != *"Merge"* ]]; then
#        echo here is in merge "$2";
        ((i++))
        echo "$i:来自分支=》$branchName"
        echo " 信息=》$2"
        echo " 提交者=》$4,邮箱=》$5"
        echo " 日期=》$3"
        # echo "HashNo is $1,Message is $2,Date is $3,Author is $4,Mail is $5"
    fi
    set +f; unset IFS
    set -f
    IFS=$'\n'       # make newlines the only separator
}

#create Commit Message
function createCommitMessage()
{
    # make newlines the only separator
    set -f
    IFS=$'\n'
    listsTag=$(git log $(git describe --tags --abbrev=0)..HEAD --oneline --date=default-local --pretty='format:%H,%s,%ad,%an,<%ae>'| git name-rev --stdin)
#    echo "current Tag is $listsTag"
    i=0
    for line in $listsTag
    do
#      echo "current Line is $line"
      echoCommitMessage $line
    done
    set +f; unset IFS
    # disable globbing
}

message="$(createCommitMessage)"
echo tag message now is ${message};
#################【 createing Verson Number 】########################
#previousTag='V-JH-20200301001-253'
vno=$(createVersionNumber $previousTag)
######################################################################
git tag -l "$vno";
git tag -a "$vno" -f -m "${message}";
git push --follow-tags;
#Send Telegram Message to Specific Group
cd /var/www/telegram-bot-bash;
export BASHBOT_HOME="$(pwd)";
source ./bashbot.sh source;
startEmoji="🤩";
telegrammsg="$startEmoji [ 已发布版本:$vno ]$startEmoji\n\n[ 发布摘要:$message ]";
send_message "$tg_chat_group_id" "$telegrammsg";