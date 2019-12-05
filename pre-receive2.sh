#!/bin/sh
# PHP CodeSniffer pre-receive hook for git
ls -la
destination_dir="/var/www/test"
destination_user="root"
destination_host="172.19.0.1"
#PHPCS_CODING_STANDARD="PEAR"
# use coding standart dir from local repo
#PHPCS_DIR_LOCAL=0

TMP_DIR=$(mktemp -d --tmpdir phpcs-pre-receive-hook.XXXXXXXX)
echo "TMP_DIR is $TMP_DIR"
mkdir "$TMP_DIR/source"

#echo "parse config"
#CONFIG_FILE=$(dirname $0)/config
#echo "config file is"$CONFIG_FILE
#if [ -e $CONFIG_FILE ]; then
#    . $CONFIG_FILE
#fi

#echo "simple check if code sniffer is set up correctly"
#if [ ! -x $PHPCS_BIN ]; then
#echo "PHP CodeSniffer bin not found or executable -> $PHPCS_BIN"
#rm -rf "$TMP_DIR"
#    exit 1
#fi

#echo "prepare our standart rules"
#if [ $PHPCS_DIR_LOCAL = 1 ]; then
#    mkdir "$TMP_DIR/standart"
#    git archive HEAD $PHPCS_CODING_STANDARD | tar -x -C "$TMP_DIR/standart"
#    PHPCS_CODING_STANDARD="$TMP_DIR/standart/$PHPCS_CODING_STANDARD"
#fi

# <oldrev> <newrev> <refname>pre-receive2.sh
while read oldrev newrev ref;
do
    list=$(git diff-tree --name-only -r $oldrev..$newrev | grep -e '.php' -e '.phtml')
#    echo "start to echo inside list **********************";
#    printf '%s\n' "${list}"
#    echo "**********************";
    #######################
    for file in ${list}; do
        containerTmpDIR="/var/www/tmp$TMP_DIR"
        echo "rp containerTmpDIR is $containerTmpDIR"
        mkdir -m 777 -p "$containerTmpDIR"
        ##################
        cp -rf "$destination_dir" "$containerTmpDIR"
        #####################################################
        gitDiff=$(git show ${newrev}:${file});
        if [ -z "$gitDiff" ]
        then
              continue
#        else
#              echo "different is $gitDiff";
        fi
        ######################################################
        containerPrjDIR="$containerTmpDIR/jianghu_entertain"
        echo "rp containerPrjDIR is $containerPrjDIR"
        mkdir -p $(dirname "$containerPrjDIR/$file")
        # dirty hack for create dir tree
        mkdir -p $(dirname "$TMP_DIR/source/$file")
        git show ${newrev}:${file} > "$TMP_DIR/source/$file"
        ######################################################
#        echo "starting Cat"
        cat "$TMP_DIR/source/$file"
        currentFile="$containerPrjDIR/$file"
        echo "rp currentFile is $currentFile"
        if [ -f "$currentFile" ]; then
          echo "replacing file"
          echo "file to replace is $currentFile"
          cp "$TMP_DIR/source/$file" "$currentFile"
          echo "content is"
          cat $currentFile
        else
          cp -f "$TMP_DIR/source/$file" "$currentFile"
        fi
    done
    #######################
    for file in ${list}; do
        #####################################################
        gitDiff=$(git show ${newrev}:${file});
        if [ -z "$gitDiff" ]
        then
              continue
#        else
#              echo "different is $gitDiff";
        fi
        ######################################################
        containerTmpDIR="/var/www/tmp$TMP_DIR"
        echo "containerTmpDIR is $containerTmpDIR"
        containerPrjDIR="$containerTmpDIR/jianghu_entertain"
        echo "containerPrjDIR is $containerPrjDIR"
        ######################################################
        currentFile="$containerPrjDIR/$file"
        echo "currentFile is $currentFile"
#        chmod -R 777 "/var/www/tmp/"
        echo "TMP_DIR IS $TMP_DIR and file is $file"
        echo "complete file is $TMP_DIR/source/$file"
        echo "now currentFile path is $currentFile"
        git show ${newrev}:${file} > "$currentFile"
        cat "$currentFile"
        RULESET="$containerPrjDIR/phpcs.xml"
        echo "RULESET is $RULESET";
        PHPCS_BIN="$containerPrjDIR/vendor/bin/phpcs"
        echo "PHPCS_BIN is $PHPCS_BIN";
        neonfile="$containerPrjDIR/phpstan.neon"
        echo "neonfile is $neonfile";
        autoloadPath="$containerPrjDIR/vendor/autoload.php"
        echo "autoloadPath is $autoloadPath";
        ########Checking Stan#############
        ####tree $containerPrjDIR;\
        ssh -l $destination_user $destination_host \
        -o PasswordAuthentication=no    \
        -o StrictHostKeyChecking=no     \
        -o UserKnownHostsFile=/dev/null \
        -p 2225                         \
        -i /var/www/harrisdock/workspace7/insecure_id_rsa    \
       "cd $containerPrjDIR/vendor/bin;\
./phpcs --standard=$RULESET $currentFile"
  EXIT_STATUS=$?
  echo "exist status is $EXIT_STATUS"
  if [ "$EXIT_STATUS" -eq "0" ]; then
    echo "\t\033[32mPHPCS Passed: $FILE\033[0m result"
  else
    echo "\t\033[41mPHPCS Failed: $FILE\033[0m"
#    rm -rf "$TMP_DIR" "$containerTmpDIR"
    exit 1
  fi
      ########Checking Stan#############
      ssh -l $destination_user $destination_host \
        -o PasswordAuthentication=no    \
        -o StrictHostKeyChecking=no     \
        -o UserKnownHostsFile=/dev/null \
        -p 2225                         \
        -i /var/www/harrisdock/workspace7/insecure_id_rsa    \
       "cd $containerPrjDIR;\
       php artisan code:analyse --error-format=table --memory-limit=1G -a $autoloadPath -c $neonfile --paths=$currentFile;"
       STAN_STATUS=$?
  echo "STAN status is $STAN_STATUS"
    if [ "$STAN_STATUS" -eq "0" ]; then
      echo 'passed'
    else
      echo "$STAN_STATUS"
      echo "Code Quality Test Failed"
      #####################
#      echo "tmpdir is $TMP_DIR and containerTmpDIR is $containerTmpDIR"
#      rm -rf "$TMP_DIR" "$containerTmpDIR"
#      exit $?
#      exit 1 #temporary blocked
    fi
        #####################
    done
done

# cleanup
#rm -rf "$TMP_DIR" "$containerTmpDIR"
exit $?
