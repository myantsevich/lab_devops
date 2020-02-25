#!/bin/bash

sudo yum install -y wget
sudo yum install java-1.8.0-openjdk-devel -y

sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
sudo wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.51/bin/apache-tomcat-8.5.51.tar.gz
sudo tar -axvf apache-tomcat-8.5.51.tar.gz -C /opt/tomcat --strip-components=1
sudo cd /opt/tomcat
sudo chown -R tomcat: /opt/tomcat

cat << EOF | sudo tee /etc/systemd/system/tomcat.service
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

sudo systemctl enable tomcat
sudo systemctl start tomcat

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat << EOF | sudo tee /etc/yum.repos.d/logstash.repo
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install -y logstash

sudo bash -c 'echo -e "
input {
  file {
    path => \"/opt/tomcat/logs/*\"
    start_position => \"beginning\"
  }
}

output {
  elasticsearch {
    hosts => [\"vm2:9200\"]
  }
  stdout { codec => rubydebug }
}" > /etc/logstash/conf.d/logstash.conf'

sudo systemctl stop logstash
# sudo systemctl restart logstash

sudo /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf&
