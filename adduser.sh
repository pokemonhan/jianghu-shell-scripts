#!/bin/bash
sftpOnlyMainUser='user-sftp-only'
srecord='apionline'
sdomain='jianghu'
projectSourceDir="/var/www"
#projectSourceDir="$HOME/projects"
dockerDir="$projectSourceDir/harrisdock"
###################################CheckOS###############################################################
OS=echo $(lsb_release -d | awk -F"\t" '{print $2}') | cut -d ' ' -f1
echo "current os is $OS"
if [ "$OS" = "CentOS" ]; then
    osType=1;
else
  #temporary ubuntu
    osType=0;
fi
###################################Create user-sftp-only account start###################################
if getent passwd $sftpOnlyMainUser > /dev/null 2>&1; then
    echo "$sftpOnlyMainUser exists"
else
    echo "$sftpOnlyMainUser does not exist"
    ftpPass=$(perl -e 'print crypt($ARGV[0], "password")' 'sftppassword')
		useradd -s /bin/bash -m -p "$ftpPass" "$sftpOnlyMainUser"
		if [ $? -eq 0 ]; then
		    echo "$sftpOnlyMainUser has been added to system!"
		    if [ $osType -eq 0 ]; then
          gpasswd -a "$sftpOnlyMainUser" sudo
        else
          echo "$sftpOnlyMainUser should be add to root permission by yourself"
        fi
		else
		  echo "Failed to add $sftpOnlyMainUser user !"
		  exit 1
		fi
fi
################################Finished Create user-sftp-only account###################################
#Create ftp user
if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	read -s -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
	  ######################################################
	  USERGROUP=$sftpOnlyMainUser
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

      #create project directory for user inside do current project stored inside current user
      projectDir="jianghu_entertain"
      parentDir="$projectSourceDir/shareprj/$username/site/$projectDir"
      echo "parent Dir is $parentDir"
      htdocDir="/home/$username/htdocs"
      userDir="$htdocDir/$projectDir"
      echo "user Dir is $userDir"
      mkdir -m 777 -p "$parentDir"
      mkdir -m 777 -p "$userDir"
      chmod 755 "/home/$username"
      echo "start bind mounting"
		  #bind mount dir
		  mountString="$parentDir $userDir none defaults,bind 0 0"
		  echo $mountString >> "/etc/fstab"
		  mounting=$(mount -a)
		  echo $mounting
      usermod -aG $USERGROUP $username
      usermod -d "/home/$username/" $username
      #add htdoc folder to be able to retrieve
      chown -R "$username:$sftpOnlyMainUser" "$htdocDir"
#      chown "$username:$sftpOnlyMainUser" $userDir
      chown root:root "/home/$username"
      #1 means Centos
      if [ $osType -eq 1 ]; then
        startssh=$(systemctl restart sshd)
      else
        startssh=$(service ssh restart)
      fi
      echo $startssh
      #to /home/harris
      nginxConfigFile="$dockerDir/nginx/sites/jianghuapi-$username.conf"
      echo "start configuration for nginx"
      domain="$srecord.$sdomain.$username"
      cat > ${nginxConfigFile} <<EOL
server {

    listen 80;
    listen [::]:80;

    server_name $domain;
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
  echo "writing host file for $username"
  echo "domain for $username is $domain"
  echo "127.0.0.1  $domain" >> /etc/hosts
  echo "docker dir is $dockerDir"
  cd "$dockerDir"
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
