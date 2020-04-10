projDir="$1"
neonfile="$2"
autoloadPath="$3"
changed_file="$4"
cd $projDir;
composer dump-autoload;
echo "now phpstan execute command is $projDir/vendor/bin/phpstan analyse -c $neonfile -a $autoloadPath $changed_file --error-format=table --memory-limit=1G"
$projDir/vendor/bin/phpstan analyse -c $neonfile -a $autoloadPath $changed_file --error-format=table --memory-limit=1G