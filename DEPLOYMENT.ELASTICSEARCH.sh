sudo apt-get update
sudo apt-get dist-upgrate

sudo dpkg-reconfigure --priority=low unattended-upgrades

sudo locale-gen en_US.UTF-8 cs_CZ.UTF-8
sudo dpkg-reconfigure locales

sudo apt-get install htop iotop


sudo apt-get install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic


adduser deployer --ingroup sudo


# elasticsearch
sudo apt-get install openjdk-7-jre
wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.2.0/elasticsearch-2.2.0.deb
sudo dpkg -i elasticsearch-2.2.0.deb

# setup bind from anywhere
echo 'network.host: 0.0.0.0' >> /etc/elasticsearch/elasticsearch.yml

# setup iptables (see http://stackoverflow.com/a/21697081)
cat > /etc/iptables.rules  <<EOF
# Generated by iptables-save v1.4.21 on Mon Apr 25 10:36:39 2016
*filter
:INPUT ACCEPT [51:4855]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [17:1960]
-A INPUT -s 84.42.154.30/32 -p tcp -m tcp --dport 9200:9400 -j ACCEPT
-A INPUT -s 81.2.243.51/32 -p tcp -m tcp --dport 9200:9400 -j ACCEPT
-A INPUT -s 81.2.251.113/32 -p tcp -m tcp --dport 9200:9400 -j ACCEPT
-A INPUT -s 81.2.242.238/32 -p tcp -m tcp --dport 9200:9400 -j ACCEPT
-A INPUT -s 127.0.0.1/32 -p tcp -m tcp --dport 9200:9400 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 9200:9400 -j REJECT --reject-with icmp-port-unreachable
COMMIT
# Completed on Mon Apr 25 10:36:39 2016
EOF

echo "    pre-up iptables-restore < /etc/iptables.rules" >> /etc/network/interfaces
