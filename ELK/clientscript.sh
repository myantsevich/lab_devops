#!/bin/bash

sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat << EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF

sudo yum  -y install --enablerepo=elasticsearch elasticsearch 

#To configure Elasticsearch to start automatically when the system boots up, run the following commands:
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch

sudo systemctl start elasticsearch


#istalling kibana from the RPM repository

cat << EOF | sudo tee /etc/yum.repos.d/kibana.repo
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

sed -i "s@// \$servers->setValue('login','attr','dn');@\$servers->setValue('login','attr','dn');@" /etc/phpldapadmin/config.php



sudo yum -y install kibana 

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service

sudo systemctl start kibana.service