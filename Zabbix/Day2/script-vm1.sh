#!/bin/bash

sudo -i
mkdir /opt/first
pass=Epam2020
yum install mariadb mariadb-server -y

/usr/bin/mysql_install_db --user=mysql --force

systemctl start mariadb
systemctl enable mariadb

mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by '$pass'"

# mysql -uroot
# create database zabbix character set utf8 collate utf8_bin;
# grant all privileges on zabbix.* to zabbix@localhost identified by 'Epam2020'; 
# quit;

rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
yum install zabbix-server-mysql -y
yum install zabbix-web-mysql -y

zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -p$pass zabbix


cat << EOF >> /etc/zabbix/zabbix_server.conf
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=$pass
EOF

setenforce 0

sed -i '/date.timezone/d' /etc/httpd/conf.d/zabbix.conf
sed -i '/always_populate/a php_value date.timezone Europe/Minsk' /etc/httpd/conf.d/zabbix.conf

echo "<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '3306';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = 'Epam2020';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';
\$ZBX_SERVER      = 'localhost';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'Zabbix Server';
\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>" > /tmp/file

mv /tmp/file /etc/zabbix/web/zabbix.conf.php
systemctl start zabbix-server
systemctl start httpd

# yum install zabbix-agent -y 
# systemctl start zabbix-agent

# sed -i 's/Server=127.0.0.1/Server=10.13.1.21/'   /etc/zabbix/zabbix_agentd.conf
# sed -i 's/ServerActive=127.0.0.1/ServerActive=10.13.1.21/'   /etc/zabbix/zabbix_agentd.conf
# sed -i 's/Hostname=Zabbix server/Hostname=vm-1/'   /etc/zabbix/zabbix_agentd.conf

# systemctl restart zabbix-agent

yum install zabbix-java-gateway
systemctl start zabbix-java-gateway
systemctl enable zabbix-java-gateway

 cat /etc/zabbix/zabbix_server.conf
