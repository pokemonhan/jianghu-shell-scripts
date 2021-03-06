#!/bin/bash
sourceDirectory="/var/www";
syncDirectory="/var/www/tmp/syncer";
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#echo $dir;
#currentScriptDir="${dir##*/}";
input="$dir/dirList.txt"

function paramRetrieve()
{
    local ProjectName=$(echo "$1"| cut -d ' ' -f1)
    local priviousHash=$(echo "$1"| cut -d ' ' -f2)
    echo "pn is $ProjectName and previoushash is $priviousHash"
	  syncDirectory "$ProjectName" "$priviousHash"
}

function escape_slashes {
    sed 's/\//\\\//g'
}

function change_line {
    local OLD_LINE_PATTERN=$1; shift
    local NEW_LINE=$1; shift
    local FILE=$1

    local NEW=$(echo "${NEW_LINE}" | escape_slashes)
    # FIX: No space after the option i.
    sed -i.bak '/^'"${OLD_LINE_PATTERN}"'/s/.*/'"${NEW}"'/' "${FILE}"
    mv "${FILE}.bak" "$dir"
}

function syncDirectory()
{
#    set +f; unset IFS
	local ProjectName="$1"
	local priviousHash="$2"
  if [ ! -d "$syncDirectory" ]
    then
   mkdir -m 777 -p "$syncDirectory"
  fi

	if [ -d "$syncDirectory/$ProjectName" ]
	then
	  rm -rf "$syncDirectory/$ProjectName";
	fi
	cp -rp "$sourceDirectory/$ProjectName" "$syncDirectory/$ProjectName"
  chmod -R 777 "$syncDirectory/$ProjectName"
  cd "$syncDirectory/$ProjectName"
  local currentHash=$(git rev-parse HEAD)
  if [[ $priviousHash == $currentHash ]]; then
#  	     upd="up-to-date"
  	     send_message "-1001677211266" "${ProjectName} have no updates" 2>/dev/null;
  else
      echo "previous hash:"$priviousHash;
      echo "current hash:"$currentHash;
      if [ -d "$syncDirectory/$ProjectName/vendor" ]
      	then
      	  rm -rf "$syncDirectory/$ProjectName/vendor";
      fi
      if [ -d "$syncDirectory/$ProjectName/writable/logs" ]
        then
        rm -rf "$syncDirectory/$ProjectName/writable/logs";
      fi
      tar -zcvf "$syncDirectory/$ProjectName.tar.gz" "$syncDirectory/$ProjectName"
#      curl -F "chat_id=-781874795" -F "photo=@/var/www/tmp/download.png" https://api.telegram.org/bot5057710392:AAGwJ2jE4uRHIaTRvqi8HYgqB6bEA0ieMU4/sendphoto
      local result=$(curl -F "chat_id=-1001677211266" -F "document=@$syncDirectory/$ProjectName.tar.gz" https://api.telegram.org/bot5057710392:AAGwJ2jE4uRHIaTRvqi8HYgqB6bEA0ieMU4/sendDocument | jq --raw-output '.ok' )
      if [ "$result" = true ] ; then
        change_line "$ProjectName" "${ProjectName} ${currentHash}" "$input";
        send_message "-1001677211266" "${ProjectName}  from ${priviousHash} to ${currentHash} " 2>/dev/null;
      fi
  fi
  rm -rf "$syncDirectory/$ProjectName" 2>/dev/null;
  rm -rf "$syncDirectory/$ProjectName.tar.gz" 2>/dev/null;
}

cd /var/www/telegram-bot-bash/DIST/telegram-bot-bash;
export BASHBOT_HOME="$(pwd)";
source ./bashbot.sh source;

while IFS= read -r line; do
    if [[ $line != *"#"* ]]; then
    	paramRetrieve "$line"
	fi
done < $input