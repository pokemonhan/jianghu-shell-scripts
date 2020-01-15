#!/bin/sh
# cd /e/projects/jianghu_entertain;
# folder="/e/test"
# for file in $folder/*; do
#   echo "${file##*/} and full is $file"
# done

toCommitDir="/e/projects/jianghu_entertain"
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
	    	commitFile $file
	    fi
    done
    set +f; unset IFS
    # disable globbing
}

function commitFile()
{
	
	#original /e/projects/jianghu_entertain/.editorconfig
	#to get .editorconfig
	currentfilePath=$(echo "$1"| cut -d ' ' -f2-)
	currentfilePath="$(echo -e "${currentfilePath}" | sed -e 's/^[[:space:]]*//')"
	# currentfilePath=$(echo "$original"| cut -d '/' -f5-)
	echo "current is $currentfilePath"
	file=${1##*/}
	echo "filename is $file"
	gitCommitMessage="优化代码规范 文件: $file"
	echo "commit Message is $gitCommitMessage"
	git -c credential.helper= -c core.quotepath=false -c log.showSignature=false add --ignore-errors -A -f -- $currentfilePath
	git -c credential.helper= -c core.quotepath=false -c log.showSignature=false commit -m "$gitCommitMessage" -- $currentfilePath
	pushStatus=$(git -c credential.helper= -c core.quotepath=false -c log.showSignature=false push --progress --porcelain)
	echo "$pushStatus"

	# echo "$(realpath ${1} | sed s:/:__:g)"
}

execEachFile

echo Press Enter...
read
