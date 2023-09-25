#!/bin/bash

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.2-x86_64.rpm
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.2-x86_64.rpm.sha512
shasum -a 512 -c elasticsearch-8.1.2-x86_64.rpm.sha512
sudo rpm --install elasticsearch-8.1.2-x86_64.rpm

sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
private_ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "http.port: 9200"  >> /etc/elasticsearch/elasticsearch.yml
echo "network.host: $private_ip"  >> /etc/elasticsearch/elasticsearch.yml
sed -i '/xpack.security.enabled: true/c\xpack.security.enabled: false' /etc/elasticsearch/elasticsearch.yml
sed -i '/xpack.security.enrollment.enabled: true/c\xpack.security.enrollment.enabled: false' /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch.service


#install kibana

yum update -y
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.1.2-x86_64.rpm
sudo rpm --install kibana-8.1.2-x86_64.rpm
private_ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "server.host: "$private_ip"">> /etc/kibana/kibana.yml
echo "server.port: "5601""  >> /etc/kibana/kibana.yml
echo "elasticsearch.hosts: [\"http://${elasticsearch}:9200\"]"  >> /etc/kibana/kibana.yml
systemctl enable --now kibana
