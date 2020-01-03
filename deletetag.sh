#!/bin/sh

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
		git tag -d "$tagName"
		git push --delete origin "$tagName"
	else
		echo "$line can live more"
	fi
	# echo "now is at $line" & echo "current tagName is $tagName and current date is $date"
}

cd /var/www/jianghu_entertain

listsTag=$(git for-each-ref --sort=taggerdate --format '%(refname:short)|%(taggerdate:short)' refs/tags | egrep -v "(^\*|release*)")
for line in $listsTag
do
  ##############[ Date time clean Tag ]#############
  handleTagDate "$line" &
  ####################################################
done
###################################################
#echo Press Enter...
#read