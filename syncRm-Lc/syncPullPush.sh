#!/bin/sh
syncDirectory="/var/www/tmp/syncDir";
input="/var/www/shell-scripts/syncRm-Lc/syncPrjs.txt"

function gitParamRetrieve()
{
	set -f; IFS=' '
	set -- $1
	# echo "ProjectName is $1,LocalGitlab is $2,RMGitlab is $3"
	gitSyncDirectory "$1" "$2" "$3"
	set +f; unset IFS
}

function gitSyncDirectory()
{
	ProjectName="$1"
	LocalGitlab="$2"
	RMGitlab="$3"
	if [ ! -d "$syncDirectory/$ProjectName" ]
	then
		# mkdir -m 777 -p "$syncDirectory/$ProjectName"
		 mkdir -p "$syncDirectory/$ProjectName"
		 output=$(git clone "$2" "$syncDirectory/$ProjectName")
		 echo $output
	fi
	cd "$syncDirectory/$ProjectName"
	checkandSetUrl $LocalGitlab $RMGitlab
}

function checkandSetUrl()
{
	LocalGitlab="$1"
	RMGitlab="$2"
	gitRMURLDetail=$(git remote -v)
	git remote set-url origin $RMGitlab
	pushOrPullAction
	git remote set-url origin $LocalGitlab
}

function pushOrPullAction()
{
	UPSTREAM=${1:-'@{u}'}
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse "$UPSTREAM")
	BASE=$(git merge-base @ "$UPSTREAM")

	if [ $LOCAL = $REMOTE ]; then
	    echo "Up-to-date"
	elif [ $LOCAL = $BASE ]; then
	    echo "Need to pull"
	    git pull
	    git push
	elif [ $REMOTE = $BASE ]; then
	    echo "Need to push"
	else
	    echo "Diverged"
	fi
}

while IFS= read -r line; do
    if [[ $line != *"#"* ]]; then
    	gitParamRetrieve "$line"
	fi
done < $input