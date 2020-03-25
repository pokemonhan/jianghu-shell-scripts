#!/bin/sh
destination_dir="$1"
tg_chat_group_id="$2"
previousTag="$3"
notag="$4"
cd "$destination_dir"

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
#        echo here is in merge "$1";
    # b27da964db4b3e1534d35866f746055378aef2bd (master),Merge branch 'feature/taibo/h5-recharge-order-offline',Tue Jan 7 15:16:32 2020,Harris,<harrisdt15f@gmail.com>
    # 01f6db6f894f18f89fc19b91747783ffd0bb6f8a (feature/taibo/h5-recharge-order-offline),:sparkles: write bb,Tue Jan 7 12:38:56 2020,Harris,<harrisdt15f@gmail.com>
    # 356ab5f64176e7b9aa5cd99d0f7c148ca12a975f (feature/taibo/h5-recharge-order-offline~1),:sparkles: write aa,Tue Jan 7 12:38:39 2020,Harris,<harrisdt15f@gmail.com>
    set -f; IFS='ê'
	  set -- $1
	  # every strange character should use double place
    #normal
    #    1 is 79f2bc20083169be392df58e18c2485118ea9dc2 (master), 2 is ,3 is Merge branch 'feature/taibo/update-seederCommand',4 is ,5 is Wed Jan 15 15:52:54 2020,6 is ,7 is Harris,8 is  9 is <harrisdt15f@gmail.com>,
    #now  is is 更新seeder生成器,匹配现有的git规则,4 is ,5 is Wed Jan 15 15:47:21 2020,6 is ,7 is tab,8 is  9 is <ckx9667131121@gmail.com>
    #    echo "1 is $1, 2 is $2,3 is $3,4 is $4,5 is $5,6 is $6,7 is $7,8 is $8 9 is $9, 10 is $10, 12 is $12"

    branchName=$(echo "$1"| cut -d ' ' -f2)
    if [[ $3 != *"Merge"* ]]; then
    #echo here is in merge "$2";
        ((i++))
        echo "$i:来自分支==>>$branchName"
        echo " 信息==>>$3"
        echo " 提交者==>>$7,邮箱==>>$9"
        echo " 日期==>>$5"
        # echo "HashNo is $1,Message is $2,Date is $3,Author is $4,Mail is $5"
    fi
    set +f; unset IFS
    set -f
    IFS=$'\n'       # make newlines the only separator
}

#create Commit Message
function createCommitMessage()
{
  previousTag="$1"
    # make newlines the only separator
    set -f
    IFS=$'\n'
    listsTag=$(git log "$previousTag"..HEAD --oneline --date=default-local --pretty='format:%Hê%sê%adê%anê<%ae>'| git name-rev --stdin)
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

function sendMsgToTgDetail() {
      tg_chat_group_id="$1"
      STRING="$2"
      # STRLENGTH=$(echo -n "$STRING" | wc -m)
      size=${#STRING}
      echo "size is $size"
      n=3
      incresement=500
      echo "length is $STRLENGTH"
      # tg max character 4096
      for (( c=0; c<=$size; c+=$incresement ))
      do
         msg="${STRING:$c:$incresement}"
         echo "now  is $msg";
          send_message "$tg_chat_group_id" "$msg";
      done
}

message="$(createCommitMessage $previousTag)"
echo tag message now is ${message};
echo "notag status is $notag";
startEmoji="🤩";
#################【 createing Verson Number 】########################
if [ -z "$notag" ] || [ "$notag" -ne 1 ]; then
  #previousTag='V-JH-20200301001-253'
  vno=$(createVersionNumber $previousTag)
  git tag -l "$vno";
  git tag -a "$vno" -f -m "${message}";
  git push --follow-tags;
  telegrammsg="$startEmoji [ 已发布版本:$vno ]$startEmoji\n\n[ 发布摘要 ]:\n$message";
else
  telegrammsg="$startEmoji [ 预发布环境已同步发布以下功能 ]$startEmoji\n\n[ 发布摘要 ]:\n$message";
fi

#Send Telegram Message to Specific Group
cd /var/www/telegram-bot-bash;
export BASHBOT_HOME="$(pwd)";
source ./bashbot.sh source;
sendMsgToTgDetail "$tg_chat_group_id" "$telegrammsg"
#scp -i /var/www/harrisdock/workspace/crontab/v7.3/jianghu-malaysia.pem -r /var/www/jianghu_entertain/storage/statics root@47.254.235.19:/var/www/jianghu_entertain/storage
#send_message "$tg_chat_group_id" "$telegrammsg";