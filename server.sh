#Your script will check if PHP, Mysql & Nginx are installed. If not present, missing packages will be installed.
#The script will then ask user for domain name. (Suppose user enters example.com)
#Create a /etc/hosts entry for example.com pointing to localhost IP.
#Create nginx config file for example.com
#Download WordPress latest version from http://wordpress.org/latest.zip and unzip it locally in example.com document root.
#Create a new mysql database for new wordpress. (database name “example.com_db” )
#Create wp-config.php with proper DB configuration. (You can use wp-config-sample.php as your template)
#You may need to fix file permissions, cleanup temporary files, restart or reload nginx config.
#Tell user to open example.com in browser (if all goes well)


#!/bin/bash
#php=$(which php)

if [ $(id -u) -eq 0 ];
then
	php=$(which php)
	mysql=$(which mysql)
	nginx=$(which nginx)
	if [ $php = '/usr/bin/php' ] && [ $mysql = '/usr/bin/mysql' ] && [ $nginx = '/usr/sbin/`ginx' ]
	then
		echo "All the Packages are already installed ";
        else
		
		if [ $php = '/usr/bin/php' ];
		then
	
			sudo apt-get install php5 php5-fpm;
		fi
		if [ $mysql = '/usr/bin/mysql' ];
		then	
		
			sudo apt-get  install mysql-server;
		fi
		if [ $nginx = '/usr/sbin/nginx' ];
		then
		
			sudo apt-get install nginx;
		fi
	fi
	echo " Enter the domain name"
	read domain
	echo "127.0.0.1		$domain" >> /etc/hosts	
	#cp /etc/nginx/sites-available/default /etc/nginx/sites-enable/$domain.conf
	mkdir /usr/share/nginx/www/$domain
	touch /usr/share/nginx/www/$domain/index.html
	echo "welcome $domain , It works" >> /usr/share/nginx/www/$domain/index.html
	touch /etc/nginx/sites-enabled/$domain.conf
	echo "server
    {
    server_name $domain;

    access_log /var/log/nginx/$domain.access.log;

	
	        error_log /var/log/nginx/$domain.error.log;

    root /usr/share/nginx/www/$domain/wordpress/;

    index index.php index.html index.htm;

    # use fastcgi for all php files
    location ~ \.php$
   {
        root /usr/share/nginx/www/$domain/wordpress/;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /usr/share/nginx/www/wordpress/$fastcgi_script_name;
        include fastcgi_params;
    }

    # deny access to apache .htaccess files
    location ~ /\.ht
   {
        deny all;
    }
}" >> /etc/nginx/sites-enabled/$domain.conf

echo " Enter the mysql usernmae -- We are going make a wordpress database "
read uname

mysqladmin -u $uname -p create $domain\_db

if [ $? -eq 0 ]
then
	echo "Database succesfully created"
else
	echo "Incorrect Username or password"
	exit 1
fi
#wget http://wordpress.org/latest.zip

#if [ $? -eq 0 ]
#then
#	echo "Wordpress download succesfully";
#else
#	exit 1;
#fi

echo -n "Enter the password for Mysql -- We need it for wp-config.php:-"
read -s password
echo $password
cp -R wordpress /usr/share/nginx/www/$domain/
mv /usr/share/nginx/www/$domain/wordpress/wp-config-sample.php /usr/share/nginx/www/$domain/wordpress/wp-config.php
sed -i s/database_name_here/$domain\_db/g /usr/share/nginx/www/$domain/wordpress/wp-config.php
sed -i s/username_here/$uname/g /usr/share/nginx/www/$domain/wordpress/wp-config.php
sed -i s/password_here/$password/g /usr/share/nginx/www/$domain/wordpress/wp-config.php


service nginx reload

clear
echo "#################################################################################"
echo " Wordpress Succesfully installed . Please open http://$domain"
echo "#################################################################################"	
else
	
	echo " You need to have root permission to run the script. "
fi
