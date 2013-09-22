#Your script will check if PHP, Mysql & Nginx are installed. If not present, missing packages will be installed.
#The script will then ask user for domain name. (Suppose user enters example.com)
#Create a /etc/hosts entry for example.com pointing to localhost IP.
#Create nginx config file for example.com
#Download WordPress latest version from http://wordpress.org/latest.zip and unzip it locally in example.com document root.
#Create a new mysql database for new wordpress. (database name “example.com_db” )
#Create wp-config.php with proper DB configuration. (You can use wp-config-sample.php as your template)
#You may need to fix file permissions, cleanup temporary files, restart or reload nginx config.
#Tell user to open example.com in browser (if all goes well)
#Written by Sagar Popat


#!/bin/bash
#php=$(which php)

if [ $(id -u) -eq 0 ];				 #check if the you are a root user or not							
then
	php=$(which php)			 # stores the path of php(installed) in php varible
	mysql=$(which mysql)			# stores the path of mysql(installed) in mysql varible
	nginx=$(which nginx)			# stores the path of nginx(installed) in nginx varible
	zip=$(which unzip)			# stores the path of unzip(installed) in unzip varible
	if [ $php = '/usr/bin/php' ] && [ $mysql = '/usr/bin/mysql' ] && [ $nginx = '/usr/sbin/nginx' ]  # check if the php,mysql,nginx are installed ornot 
	then
	clear
		echo "All the Packages are already installed "
        else
		
		if [[ $php = '/usr/bin/php' ]]      			# check if the php is installed 
		then
			echo "PHP is already installed"
		else
	 		apt-get install php5 php5-fpm
		fi
		if [[ $mysql = '/usr/bin/mysql' ]]  			# check if the mysql is installed or not 
		then
			echo "Mysql is already installed"	
		else
			apt-get  install mysql-server
		fi
		if [[ $nginx = '/usr/sbin/nginx' ]]			# check if the nginx is installed or not 
		then
			echo "nginx is already installed"
		else
			sudo apt-get install nginx;
		fi
	fi
	echo " Enter the domain name"					#read the domain name
	read domain
	echo "127.0.0.1		$domain" >> /etc/hosts	                 # add entry to hosts file
	#cp /etc/nginx/sites-available/default /etc/nginx/sites-enable/$domain.conf
	mkdir /usr/share/nginx/www/$domain				#create the directory of domain name
	touch /usr/share/nginx/www/$domain/index.html			#create index page for testing
	echo "welcome $domain , It works" >> /usr/share/nginx/www/$domain/index.html #Add contains to the index file
	touch /etc/nginx/sites-enabled/$domain.conf			#create the virtual hosting configuration file
	echo "server							#add configuration to the domain config file
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

echo " Enter the mysql usernmae -- We are going make a wordpress database "      #read mysqlusername to add database
read uname

mysqladmin -u $uname -p create $domain\_db					# create database like domainname_db

if [ $? -eq 0 ]									#check mysqladmin has any error
then
	echo "Database succesfully created"
else
	echo "Incorrect Username or password"
	exit 1
fi
wget http://wordpress.org/latest.zip 					# Download the Wordpress by using wget

if [ $? -eq 0 ]								#check the error code for wget command
then
	echo "Wordpress download succesfully";
else
	echo "Can't Download Wordpress.Check your internet Connectivity"
	exit 1;
fi

echo -n "Enter the password for Mysql -- We need it for wp-config.php:-"   
read -s password							#read password for mysql
#echo $password
if [ $zip='/usr/bin/unzip' ]
then
	echo "unzip is already installed"
else
	apt-get install unzip;
fi
unzip latest.zip
cp -R wordpress /usr/share/nginx/www/$domain/				#copy wordpress to domain documentroot
mv /usr/share/nginx/www/$domain/wordpress/wp-config-sample.php /usr/share/nginx/www/$domain/wordpress/wp-config.php  # rename the filename from wp-config-sample.php to wp-config.php
sed -i s/database_name_here/$domain\_db/g /usr/share/nginx/www/$domain/wordpress/wp-config.php                  # Editing the wp-config.php file according to the occureance
sed -i s/username_here/$uname/g /usr/share/nginx/www/$domain/wordpress/wp-config.php				# Editing the wp-config.php file according to the occureance							
sed -i s/password_here/$password/g /usr/share/nginx/www/$domain/wordpress/wp-config.php				# Editing the wp-config.php file according to the occureance


service nginx reload								#reloading the server
		

echo "#################################################################################"
echo " Wordpress Succesfully installed . Please open http://$domain"
echo "#################################################################################"	
else
	
	echo " You need to have root permission to run the script. "
fi
