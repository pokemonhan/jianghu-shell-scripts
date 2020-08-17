dockerlist=$(docker ps -a)
echo "$dockerlist"
####################################
##        EXECUTE LIVE            ##
####################################
# winpty docker-compose exec --user=laradock workspace73 bash

function getContainerId() {

  local workspaceName="$1";
    #get Id of Container
  local workspaceIdLong=$(docker inspect -f  '{{.Id}}'  $workspaceName)
  #get shortcut Id of Container
  local workspaceId=$(cut -c-12 <<< "$workspaceIdLong")
  echo "$workspaceId"
}

####################################
##      Empty Live_Game DB First  ##
####################################
mysql5ConName='harris_mysql5_1'
mysql5ConId=$(getContainerId "$mysql5ConName");
docker cp mysqlargs/ ${mysql5ConId}:/tmp/mysqlScripts;
#References https://gist.github.com/ticean/965614
docker cp shells/drop-mysql-tables.sh ${mysql5ConId}:/tmp/mysqlScripts/;
docker exec $mysql5ConName bash -c "ls /tmp/mysqlScripts/*;chmod -R +x /tmp/mysqlScripts;";
docker exec $mysql5ConName bash -c 'bash /tmp/mysqlScripts/live_game_drop.sh';

####################################
##      Import Live_Game DB Data   ##
####################################
docker exec $mysql5ConName bash -c "mkdir /tmp/mysqlScripts";
docker cp import_sql/live_game_init.sh ${mysql5ConId}:/tmp/mysqlScripts/live_game_init.sh;
docker cp /d/project/deploy/init_sql/hswl_live_game.sql ${mysql5ConId}:/tmp/mysqlScripts/hswl_live_game.sql;
docker cp /d/project/deploy/init_sql/hswl_live_game_data.sql ${mysql5ConId}:/tmp/mysqlScripts/hswl_live_game_data.sql;
docker exec $mysql5ConName bash -c "ls /tmp/mysqlScripts/*;chmod -R +x /tmp/mysqlScripts;";
docker exec $mysql5ConName bash -c 'bash /tmp/mysqlScripts/live_game_init.sh;'
#break With User Control
echo Press Enter...
read



