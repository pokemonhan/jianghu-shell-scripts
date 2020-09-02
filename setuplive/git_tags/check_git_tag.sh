#!/bin/bash
#references: https://stackoverflow.com/questions/3404936/show-which-git-tag-you-are-on
#version compare references: https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash

workspace=d:/project/webroot
targetTag=v1.2.8

function checkGitTag() {
        echo $(git fetch -t)
        if GIT_DIR= $(git tag --list | egrep -q "^$1$")
        then
            echo "Found tag $1"
            return 0
        else
            echo "Tag $1 没找到"
            return 1
        fi
}

function vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

calVerComp () {
    vercomp $1 $2
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [[ $op != $3 ]]
    then
        echo "FAIL: Expected '$3', Actual '$op', Arg1 '$1', Arg2 '$2'";
        return 1;
    else
        echo "Pass: '$1 $op $2'"
    fi
}

cd $workspace;
currentVersion=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'));
STATUS=$?
echo "Status is $STATUS";
echo "currentVersion is $currentVersion";
    if [ $STATUS -ne 0 ]; then
        echo "执行: 更新 tags 异常"
        exit 1
    fi
    if [ -z "$currentVersion" ];then
        echo "目前不在 tags 中"
        echo $(git rev-parse --abbrev-ref HEAD);
        exit 1
    fi
    #######################################
    echo $(checkGitTag $targetTag);
    FTSTATUS=$?
    if [ $FTSTATUS -ne 0 ]; then
        exit 1
    fi
    #######################################
    targetVersionNo=${targetTag:1}
    currentVersionNo=${currentVersion:1}
    echo targetVersion is $targetVersionNo;
    echo currentVersionNo is $currentVersionNo;
    gtResult=$(calVerComp $targetVersionNo $currentVersionNo '>')
    GTSTATUS=$?
    echo "gtResult is $gtResult";
    echo "GTSTATUS is $GTSTATUS";
    if [ $GTSTATUS -ne 0 ]; then
        exit 0
    fi
    git checkout -q $targetTag

echo Press Enter...
read



