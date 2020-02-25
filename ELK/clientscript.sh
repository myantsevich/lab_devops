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


#To configure Elasticsearch to start automatically when the system boots up:
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch

sudo sed -i 's@#network.host: 192.168.0.1@network.host: 127.0.0.1@' /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's@#http.port: 9200@http.port: 9200@' /etc/elasticsearch/elasticsearch.yml
sudo echo -e "http.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
sudo echo -e "transport.host: localhost" >> /etc/elasticsearch/elasticsearch.yml
sudo echo -e "action.auto_create_index: .monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*" >> /etc/elasticsearch/elasticsearch.yml

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

sudo yum -y install kibana 
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable kibana.service

sudo sed -i 's@#server.port:@server.port:@' /etc/kibana/kibana.yml
sudo sed -i 's@#server.host: "localhost"@server.host: "0.0.0.0"@' /etc/kibana/kibana.yml
sudo sed -i 's@#server.name: "your-hostname"@server.name: "vm2"@' /etc/kibana/kibana.yml
sudo sed -i 's@#elasticsearch.hosts@elasticsearch.hosts@' /etc/kibana/kibana.yml
sudo sed -i 's@#logging.verbose: false@logging.verbose: true@' /etc/kibana/kibana.yml


sudo systemctl start kibana.service



