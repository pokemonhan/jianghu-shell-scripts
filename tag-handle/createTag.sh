#!/bin/sh
counter=0;
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
		dayVno="${dVno:8:3}"
		dayVno="$(incnumstr $dayVno 1)"
		pv="$(incnumstr $4 1)"
		versionNumber="$versionPrefix${dayVno}-$pv"
		echo "$versionNumber"
	fi
	set +f; unset IFS
}

while [[ ${counter} -lt 20 ]]
do
  message="$(git log -1 --skip $counter --pretty=%B)"
  if [[ ${message} == *"Merge"* ]]; then
   echo here is in merge "${message}";
    ((counter++))
   else
   echo here is normal msg "${message}";
      break
   fi
  echo count is "$counter" and message is "$message"
done
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