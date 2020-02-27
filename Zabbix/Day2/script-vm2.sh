#!/bin/bash

sudo -i

mkdir /opt/second
rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm   

yum install zabbix-agent -y 

systemctl start zabbix-agent

sed -i 's/Server=127.0.0.1/Server=10.13.1.21/'   /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=10.13.1.21/'   /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=vm-1/'   /etc/zabbix/zabbix_agentd.conf


systemctl restart zabbix-agent