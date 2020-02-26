#!/bin/bash

sudo -i


sudo -i
mkdir /opt/second
rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm

yum install zabbix-agent -y 

systemctl start zabbix-agent

sed -i 's/Server=127.0.0.1/Server=10.13.1.21/'   /etc/zabbix/zabbix_agentd.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=10.13.1.21/'   /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix server/Hostname=vm-1/'   /etc/zabbix/zabbix_agentd.conf


systemctl restart zabbix-agent


yum install -y wget
yum install java-1.8.0-openjdk-devel -y

groupadd tomcat
mkdir /opt/tomcat
useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.51/bin/apache-tomcat-8.5.51.tar.gz
tar -axvf apache-tomcat-8.5.51.tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
chown -R tomcat: /opt/tomcat

cat << EOF > /etc/systemd/system/tomcat.service
[Unit]

Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]

Type=forking
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms256M -Xmx512M -server -XX:+UseParallelGC -verbose:gc -Xloggc:/opt/tomcat/logs/gc_log -XX:+HeapDumpOnOutOfMemoryError  -XX:HeapDumpPath=/opt/tomcat/logs/heap_dump -XX:+PrintGCDetails -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime -XX:+PrintHeapAtGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID
User=tomcat
Group=tomcat

[Install]

WantedBy=multi-user.target
EOF


wget https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war 
cp ./sample.war /opt/tomcat/webapps

cat << EOF > /opt/tomcat/bin/setenv.sh
export JAVA_OPTS="-Dcom.sun.management.jmxremote=true \
					-Djava.rmi.server.hostname=10.13.1.23 \
					-Dcom.sun.management.jmxremote.port=12345 \
					-Dcom.sun.management.jmxremote.rmi.port=12346 \
					-Dcom.sun.management.jmxremote.ssl=false  \
					-Dcom.sun.management.jmxremote.authenticate=false"
EOF


systemctl enable tomcat
systemctl start tomcat
