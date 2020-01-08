#!/bin/sh
destination_dir="$1"
currentScriptDir="$2"
tg_chat_group_id="$3"
version="$4"
echo "specific version is $version"
#/var/www/jianghu_entertain
cd "$destination_dir"
if [[ -z $version ]]; then
    #current Latest Tag
    #  version="$(git describe --abbrev=0)"
    #Previous Tag before Latest Tag
  version="$(git describe --abbrev=0 $(git describe --abbrev=0)^)"
  echo "previous version is $version"
fi
if git rev-parse $version >/dev/null 2>&1
then
      # Push command over ssh
      # git push -f
      # git reset --hard "jianghu-5"
      # grep 'at' <<< "HEAD is now at a3cc6ba hello1" | sed 's/^.*at //'
      # git commit -m "版本回滚到 jianghu-5"
      # git log -1 --pretty=%B #final first commit message
      echo "Found tag"
      reSetedFullMsg=$(git reset --hard $version);
      echo "reSetedFullMsg is $reSetedFullMsg";
      reSetedMsg=$(grep 'at' <<< $reSetedFullMsg | sed 's/^.*at //');
      echo reSetedMsg is $reSetedMsg;
      git reset --soft HEAD@{1};
      git commit -m "版本回滚到 $version $reSetedMsg ";
      git push origin master;
      bash /var/www/$currentScriptDir/localGitlabDeploy/laravel-flow/artisan-command.sh $destination_dir;
      bash /var/www/$currentScriptDir/localGitlabDeploy/tag-handle/createTag.sh $destination_dir $tg_chat_group_id;
else
    echo "Tag not found" !!!!!!!!!!!!!!!!!!!!!!
fi;
    echo "Completing Rollback!"