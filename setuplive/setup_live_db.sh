dockerlist=$(docker ps -a)
echo "$dockerlist"
####################################
##        EXECUTE LIVE            ##
####################################
# winpty docker-compose exec --user=laradock workspace73 bash

function getContainerId() {

  local workspace73Name="$1";
    #get Id of Container
  local workspaceIdLong=$(docker inspect -f  '{{.Id}}'  $workspace73Name)
  #get shortcut Id of Container
  local workspaceId=$(cut -c-12 <<< "$workspaceIdLong")
  echo "$workspaceId"
}

workspace73Name='harris_workspace73_1'
#create tmp directory for shell execution
#docker exec $workspace73Name bash -c "mkdir –p /tmp/live_setup";
workspace73Id=$(getContainerId "$workspace73Name");
#echo "here is $workspace73Id Fine";
####################################
##        Empty Live DB First      ##
####################################
mysql5ConName='harris_mysql5_1'
mysql5ConId=$(getContainerId "$mysql5ConName");
docker cp mysqlargs/ ${mysql5ConId}:/tmp/mysqlScripts;
#References https://gist.github.com/ticean/965614
docker cp shells/drop-mysql-tables.sh ${mysql5ConId}:/tmp/mysqlScripts/;
docker exec $mysql5ConName bash -c "ls /tmp/mysqlScripts/*;chmod -R +x /tmp/mysqlScripts;";
docker exec $mysql5ConName bash -c 'bash /tmp/mysqlScripts/live_drop.sh';

####################################
##   Execution of LiveMigration   ##
####################################
#echo "docker cp shells ${workspace73Id}:/tmp/live_setup";
docker cp shells/ ${workspace73Id}:/tmp/live_setup
docker exec $workspace73Name bash -c "ls /tmp/live_setup/*;chmod -R +x /tmp/live_setup;"
docker exec $workspace73Name bash -c "bash /tmp/live_setup/live_migration.sh;"

####################################
##        Import Live DB First     ##
####################################
docker exec $mysql5ConName bash -c "mkdir /tmp/mysqlScripts";
docker cp import_sql/live_init.sh ${mysql5ConId}:/tmp/mysqlScripts/live_init.sh;
docker cp /d/project/deploy/init_sql/live_init_data.sql ${mysql5ConId}:/tmp/mysqlScripts/live_init_data.sql;
docker exec $mysql5ConName bash -c "ls /tmp/mysqlScripts/*;chmod -R +x /tmp/mysqlScripts;";
docker exec $mysql5ConName bash -c 'bash /tmp/mysqlScripts/live_init.sh;'
#break With User Control
echo Press Enter...
read



