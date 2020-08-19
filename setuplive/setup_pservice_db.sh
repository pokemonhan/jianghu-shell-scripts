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
#docker exec $workspace73Name bash -c "mkdir –p /tmp/pservice_setup";
workspace73Id=$(getContainerId "$workspace73Name");
#echo "here is $workspace73Id Fine";
####################################
##  Empty Service Related DB First ##
####################################
mysql5ConName='harris_mysql5_1'
mysql5ConId=$(getContainerId "$mysql5ConName");
docker cp mysqlargs/ ${mysql5ConId}:/tmp/mysqlScripts;
#References https://gist.github.com/ticean/965614
docker cp shells/drop-mysql-tables.sh ${mysql5ConId}:/tmp/mysqlScripts/;
docker exec $mysql5ConName bash -c "ls /tmp/mysqlScripts/*;chmod -R +x /tmp/mysqlScripts;";
docker exec $mysql5ConName bash -c 'bash /tmp/mysqlScripts/pservice_drop.sh';
docker exec $mysql5ConName bash -c 'bash /tmp/mysqlScripts/pservicebusiness_drop.sh';
docker exec $mysql5ConName bash -c 'bash /tmp/mysqlScripts/pservicepay_drop.sh';
docker exec $mysql5ConName bash -c 'rm -rf /tmp/mysqlScripts';
####################################
##   Execution of LiveMigration   ##
####################################
#echo "docker cp shells ${workspace73Id}:/tmp/pservice_setup";
docker cp shells/ ${workspace73Id}:/tmp/pservice_setup
docker exec $workspace73Name bash -c "ls /tmp/pservice_setup/*;chmod -R +x /tmp/pservice_setup;"
docker exec $workspace73Name bash -c "bash /tmp/pservice_setup/pservice_migration.sh;"

#break With User Control
echo Press Enter...
read



