dockerlist=$(docker ps -a)
echo "$dockerlist"
#### EXECUTE LIVE #####

# winpty docker-compose exec --user=laradock workspace73 bash

function getContainerId() {

  local containerName="$1";
    #get Id of Container
  local workspaceIdLong=$(docker inspect -f  '{{.Id}}'  $containerName)
  #get shortcut Id of Container
  local workspaceId=$(cut -c-12 <<< "$workspaceIdLong")
  echo "$workspaceId"
}

containerName='harris_workspace73_1'
#create tmp directory for shell execution
#docker exec $containerName bash -c "mkdir –p /tmp/live_setup";
workspace73Id=$(getContainerId "$containerName");
#echo "here is $workspace73Id Fine";
# Execution of Migration Shell Script
#echo "docker cp shells ${workspace73Id}:/tmp/live_setup";
docker cp shells/ ${workspace73Id}:/tmp/live_setup
docker exec $containerName bash -c "ls /tmp/live_setup/*;chmod -R +x /tmp/live_setup;"
docker exec $containerName bash -c "bash /tmp/live_setup/live_migration.sh;"

#break With User Control
echo Press Enter...
read



