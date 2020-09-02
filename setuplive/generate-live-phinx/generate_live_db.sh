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
#docker exec $workspace73Name bash -c "mkdir –p /tmp/cn-shells";
workspace73Id=$(getContainerId "$workspace73Name");
#echo "here is $workspace73Id Fine";
####################################
##   Execution of LiveMigration   ##
####################################
#echo "docker cp shells ${workspace73Id}:/tmp/cn-shells";
docker cp cn-shells/ ${workspace73Id}:/tmp/
docker exec $workspace73Name bash -c "ls /tmp/cn-shells/*;chmod -R +x /tmp/cn-shells;"
docker exec $workspace73Name bash -c "bash /tmp/cn-shells/live-db-generator.sh;"

#break With User Control
echo Press Enter...
read



