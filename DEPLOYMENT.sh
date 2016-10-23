sudo apt-get update
sudo apt-get upgrade

sudo dpkg-reconfigure --priority=low unattended-upgrades

# in case of locale problems ``` perl: warning: Setting locale failed.```
sudo locale-gen en_US.UTF-8 cs_CZ.UTF-8
sudo dpkg-reconfigure locales
sudo dpkg-reconfigure tzdata  # vybrat prahu

#basic
sudo apt-get install htop iotop

#git install
sudo apt-get install -y git-core

sudo apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate

#for backup
sudo apt-get install lftp

# because of json gem:
sudo apt-get install libgmp-dev libgmp3-dev

# because of pg gem:
sudo apt-get install libpq-dev

sudo apt-get install postgresql
sudo apt-get install postgresql-9.3-postgis-2.1 postgresql-9.3-postgis-2.1-scripts postgis
sudo apt-get install libgdal1-dev #optionaly for raser support


#node
sudo apt-get instsall nodejs-legacy

#..and maybe:
sudo apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core \
   zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev \
   libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison

#nodejs: In case you need javascript runtime to be installed (Ubuntu 12.10):
#sudo apt-get -y install python-software-properties python g++ make
sudo apt-get -y install software-properties-common python g++ make
sudo add-apt-repository ppa:chris-lea/node.js #in case of error: sudo apt-get install apt-file && apt-file update
sudo apt-get update
sudo apt-get install nodejs


#vim
sudo apt-get install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic

# #ngnix
# sudo apt-get install nginx

adduser deployer --ingroup sudo

#install ruby
#curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled
sudo -u deployer -H -i sh -c "curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled"
sudo -u deployer -H -i sh -c "curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled"
echo "source ~/.profile" >> /home/deployer/.bash_profile
#sudo -u deployer -i sh -c "gem install rails --no-ri --no-rdoc"
sudo -u deployer -H -i sh -c "rvm install ruby-2.3.0"
sudo -u deployer -H -i sh -c "rvm use ruby-2.3.0"
sudo -u deployer -H -i sh -c "rvm use --default ruby-2.3.0"



#vim ```janus``` plugin (https://github.com/carlhuda/janus)
sudo -u deployer -i sh -c "curl -Lo- https://bit.ly/janus-bootstrap | bash"


#setting swap:
# #https://www.digitalocean.com/community/articles/how-to-add-swap-on-ubuntu-12-04
# dd if=/dev/zero of=/swapfile bs=1024 count=1024k
# mkswap /swapfile
# swapon /swapfile
# swapon -s
# echo "	 /swapfile       none    swap    sw      0       0" >> /etc/fstab
# #echo 0 > /proc/sys/vm/swappiness  #0 is to low, assets are not compiled
# chown root:root /swapfile
# chmod 0600 /swapfile


# elasticsearch
sudo apt-get install openjdk-7-jre
wget https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.2.0/elasticsearch-2.2.0.deb
sudo dpkg -i elasticsearch-2.2.0.deb

# Clone repos

gem install bundle
mkdir las && cd las
git clone git@github.com:lksv/ruian_model.git
git clone git@github.com:lksv/local_administration_model.git
cd local_administration_model/ && bundle install --jobs 4
git clone git@github.com:lksv/las_control.git
cd las_control && bundle install --jobs 4 --without development test

# Prepare .env
## copy / cretate .env in ~/las directory
cd las_control && ln -s ../.env
cd local_administration_model && ln -s ../.env


#postgres
     sudo -u postgres psql
     create database "ruian";
     create role ob with createdb login password 'ob';
     GRANT ALL PRIVILEGES ON DATABASE ruian TO ob;
     \c ruian
     CREATE EXTENSION postgis;
     CREATE EXTENSION postgis_topology;


     sudo -u postgres psql
     create role deployer with createdb login password 'password';
     ALTER USER deployer WITH SUPERUSER;

sudo echo "deployer deployer deployer" >> /etc/postgresql/9.3/main/pg_ident.conf

# Prepare DB
cd local_administration_model
#modify config/database.yml
ENV=production RAILS_ENV=production rake db:create db:migrate

# setup restart of services
cat >>/etc/crontab <<EOF
# 05 1  * * * root  /usr/sbin/service puma-manager restart && /usr/sbin/service workers restart
# 58 5  * * * root  /usr/sbin/service puma-manager restart && /usr/sbin/service workers restart
05 1  * * * root  /bin/systemctl restart puma.service && /bin/systemctl restart sidekiq.service
58 5  * * * root  /bin/systemctl restart puma.service && /bin/systemctl restart sidekiq.service
EOF
