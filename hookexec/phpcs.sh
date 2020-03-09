projDir="$1"
RULESET="$2"
changed_file="$3"
cd $projDir/vendor/bin;
echo "now execute command is ./phpcs --standard=$RULESET $changed_file"
./phpcs --standard=$RULESET $changed_file