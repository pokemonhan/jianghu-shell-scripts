#!/bin/sh
destination_dir="$1"

function handleTagDate()
{
    local line="$1"
	local tagName=$(echo "$line"| cut -d '|' -f1)
	local date=$(echo "$line"| cut -d '|' -f2)
	#90 days ago
	local timeago='2 days ago'
	local dtSec=$(date --date "$date" +'%s')
	local taSec=$(date --date "$timeago" +'%s')
	# echo "INFO: dtSec=$dtSec, taSec=$taSec" >&2
	if [[ $dtSec -lt $taSec ]]; then
		echo "$line alreay 2 days ago"
		deleteTag=$(git tag -d "$tagName")
		echo "$deleteTag"
		pushStatus=$(git push --delete origin "$tagName")
		echo "$pushStatus"
	else
		echo "$line can live more"
	fi
	# echo "now is at $line" & echo "current tagName is $tagName and current date is $date"
}

#/var/www/jianghu_entertain
cd "$destination_dir"
#Sync deleted Remote Tag to Local
git tag -l | xargs git tag -d && git fetch -t;
#Check which tag are older than specific days to remove
listsTag=$(git for-each-ref --sort=taggerdate --format '%(refname:short)|%(taggerdate:short)' refs/tags | egrep -v "(^\*|release*)")
pids=()
for line in $listsTag
do
  ##############[ Date time clean Tag ]#############
  handleTagDate "$line" &
  pids+=($!)
  ####################################################
done
for pid in "${pids[@]}"; do
      #
      # Waiting on a specific PID makes the wait command return with the exit
      # status of that process. Because of the 'set -e' setting, any exit status
      # other than zero causes the current shell to terminate with that exit
      # status as well.
      #
      wait "$pid"
      exit_status=$?
      lastpid=$!
      if [ "$exit_status" -gt 0 ]; then
        echo "current exist status is $exit_status at gt 0"
        exit 1
      fi
    done
###################################################
#echo Press Enter...
#read