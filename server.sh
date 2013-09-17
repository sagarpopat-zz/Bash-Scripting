#Script that will check wheather your server has packages like mysql,php,nginx. If it's not installed script will
# automatically installed in server

#!/bin/bash
#php=$(which php)

if [ $(id -u) -eq 0 ];                                      # Check wheather you are a root user or not
then
        php=$(which php)
        mysql=$(which mysql)
        nginx=$(which snginx)
        if [ -n $php ] && [ -n $mysql ] && [ -n $nginx ];     # Check if its non empty or not
        then
                echo "Packages are already Installed";
        else

                if [ -z $php ];                               #Check PHP varible is null or not
                then

                       apt-get install php5                   #install php
                fi
                if [ -z $mysql ];                             #Check Mysql varbile is null or not
                then

                       apt-get  install mysql-server;         #Install Mysql-server
                fi
                if [ -z $nginx ];                             #Check nginx varible is null or not
                then

                        sudo apt-get install nginx;           # Install nginx server
                fi
        fi
else

        echo " You need to have root permission to run the script. "
fi
