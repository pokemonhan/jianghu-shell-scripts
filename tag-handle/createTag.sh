#!/bin/sh
counter=0;
destination_dir="$1"
version_prefix="$2"
BUILD_NUMBER="$3"
tg_chat_group_id="$4"
cd "$destination_dir"
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
git tag -l "$version_prefix-$BUILD_NUMBER";
git tag -a "$version_prefix-$BUILD_NUMBER" -f -m "${message}";
git push --follow-tags;
#Send Telegram Message to Specific Group
cd /var/www/telegram-bot-bash;
export BASHBOT_HOME="$(pwd)";
source ./bashbot.sh source;
startEmoji="🤩🤩🤩🤩🤩🤩";
telegrammsg="$startEmoji [ 已发布版本:$version_prefix-$BUILD_NUMBER ]$startEmoji\n\n[ 发布摘要:$message ]";
send_message "$tg_chat_group_id" "$telegrammsg";