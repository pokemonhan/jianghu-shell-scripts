#!/bin/bash
if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	read -s -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
	  ######################################################
	  USERGROUP='user-sftp-only'
	  grep $USERGROUP /etc/group 2>&1>/dev/null
  if [ $? != 0 ]
  then
      echo "Group Name you entered $USERGROUP is not valid\n"
      echo "Creating Abort!\n"
      exit 1
  else
#      useradd -g $USERGROUP -d /home/$username -s /bin/bash -m $username
#      passwd $username
      pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		  useradd -s /bin/bash -m -p $pass $username
		  [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"

      #create project directory for user
      projectDir="jianghu_entertain"
      parentDir="/home/harris/projects/shareprj/$username/site/$projectDir"
      echo "parent Dir is $parentDir"
      userDir="/home/$username/htdocs/$projectDir"
      echo "user Dir is $userDir"
      mkdir -m 777 -p "$parentDir"
      mkdir -m 777 -p "$userDir"
      echo "start bind mounting"
		  #bind mount dir
		  mountString="$parentDir $userDir none defaults,bind 0 0"
		  echo $mountString >> "/etc/fstab"
		  mounting=$(mount -a)
		  echo $mounting
      usermod -aG $USERGROUP $username
      usermod -d "/home/$username/" $username
      chown "$username:user-sftp-only" $userDir
      chown root:root "/home/$username"
      startssh=$(service ssh restart)
      echo $startssh
      nginxConfigFile="/home/harris/projects/harrisdock/nginx/sites/jianghuapi-$username.conf"
      echo "start configuration for nginx"
      cat > ${nginxConfigFile} <<EOL
server {

    listen 80;
    listen [::]:80;

    server_name api.jianghu.$username;
    root /var/www/shareprj/$username/site/$projectDir/public;
    index index.php index.html index.htm;

    location / {
         try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \.php\$ {
        try_files \$uri /index.php =404;
        fastcgi_pass php-fpm-tom:9000;
        fastcgi_index index.php;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_AUTHORIZATION \$http_authorization;
        #fixes timeouts
        fastcgi_read_timeout 600;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/letsencrypt/;
        log_not_found off;
    }

    error_log /var/log/nginx/jianghu_${username}_error.log;
    access_log /var/log/nginx/jianghu_${username}_access.log;
}
EOL
  chmod 777 $nginxConfigFile
  domain="api.jianghu.$username"
  echo "writing host file for $username"
  echo "domain for $username is $domain"
  echo "127.0.0.1  $domain" >> /etc/hosts
  cd /home/harris/projects/harrisdock
  docker-compose stop nginx
  docker-compose up -d nginx
  echo "done created user"
  fi
	  ######################################################
	fi
else
	echo "Only root may add a user to the system"
	exit 2
fi
