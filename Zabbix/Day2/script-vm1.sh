#!/bin/bash

sudo -i

mkdir /opt/first

sleep 60s
yum install mariadb-server -y

/usr/bin/mysql_install_db --user=mysql --force

pass=Epam2020

systemctl start mariadb
systemctl enable mariadb

mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by '$pass'"

rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm   
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

yum install zabbix-agent -y 
systemctl start zabbix-agent

sed -i 's/Server=127.0.0.1/Server=10.13.1.21/'   /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=10.13.1.21/'   /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=vm-1/'   /etc/zabbix/zabbix_agentd.conf

systemctl restart zabbix-agent

yum install zabbix-java-gateway -y
sed -i 's|# JavaGateway=|JavaGateway=10.13.1.21|' /etc/zabbix/zabbix_server.conf
sed -i 's|# JavaGatewayPort=10052|JavaGatewayPort=10052|' /etc/zabbix/zabbix_server.conf
sed -i 's|# StartJavaPollers=0|StartJavaPollers=5|' /etc/zabbix/zabbix_server.conf

systemctl start zabbix-java-gateway
systemctl enable zabbix-java-gateway
systemctl restart zabbix-server



#API connect. Create new host

JSON='
{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "Admin",
        "password": "zabbix"
    },
    "id": 1
}
'
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON" "http://10.13.1.21/zabbix/api_jsonrpc.php" | cut -d '"' -f8)


JSON='
{
    "jsonrpc": "2.0",
    "method": "hostgroup.create",
    "params": {
        "name": "Linux servers API"
    },
    "auth": "'$TOKEN'",
    "id": 1
}
'

GROUP=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON" "http://10.13.1.21/zabbix/api_jsonrpc.php" | cut -d '"' -f10)
echo "Custom group ID:$GROUP"


JSON='
{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "vm-3",
        "interfaces": [
            {
            "type": 4,
                "main": 1,
                "useip": 1,
                "ip": "10.13.1.23",
                "dns": "",
                "port": "12345"
            },
            {
            "type": 4,
                "main": 0,
                "useip": 1,
                "ip": "10.13.1.23",
                "dns": "",
                "port": "8097"
            }
        ],
        "groups": [
            {
                "groupid": "'$GROUP'"
            }
        ],
        "templates": [
            {
            "templateid": "10260"
            }
        ]     
    },
    "auth": "'$TOKEN'",
    "id": 1
}
'


HOST=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON" "http://10.13.1.21/zabbix/api_jsonrpc.php" | cut -d '"' -f10)
echo "Created new host - vm-3 with ID:$HOST"

JSON='
{
    "jsonrpc": "2.0",
    "method": "template.create",
    "params": {
        "host": "Custom template",
        "groups": {
            "groupid": "'$GROUP'"
        },
        "hosts": [
            {
                "hostid": "'$HOST'"
            }
        ]
    },
    "auth": "'$TOKEN'",
    "id": 1
}'

TEMPLATE=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON" "http://10.13.1.21/zabbix/api_jsonrpc.php" | cut -d '"' -f10)
echo "Custom template ID:$TEMPLATE"

JSON='
{
    "jsonrpc": "2.0",
    "method": "host.create",
    "params": {
        "host": "vm-2",
        "interfaces": [
            {
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": "10.13.1.22",
                "dns": "",
                "port": "10050"
            }
        ],
        "groups": [
            {
                "groupid": "'$GROUP'"
            }
        ],
         "templates": [
            {
            "templateid": "10001"
            }
        ]    
    },
    "auth": "'$TOKEN'",
    "id": 1
}
'

AGENT=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON" "http://10.13.1.21/zabbix/api_jsonrpc.php" | cut -d '"' -f10)
echo "New agent host - vm-2 with ID:$AGENT"








ttt='{
    "jsonrpc": "2.0",
    "method": "template.get",
    "params": {
        "output": ["templateid",
           "name"
           ],
        "filter": {
            "host": [
                "Template App Apache Tomcat JMX",
                "Template App Zabbix Agent",
                "Template OS Linux"
            ]
        }
    },
    "auth": "'$TOKEN'",
    "id": 1
}'
fff=$(curl -X POST -H 'Content-type: application/json-rpc' -d "$ttt"  "http://10.13.1.21/zabbix/api_jsonrpc.php")

# sed -i "s@changeme@$token@" gettempl.json
# curl -X POST -H 'Content-type: application/json-rpc' -d @gettempl.json  http://vm1/zabbix/api_jsonrpc.php