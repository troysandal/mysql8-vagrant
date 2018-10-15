#!/usr/bin/env bash
#https://forums.mysql.com/read.php?11,666369,666592#msg-666592

export DEBIAN_FRONTEND="noninteractive";
sudo apt-get update
sudo apt-get install -y debconf-utils
sudo debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-server select mysql-8.0'
sudo apt-get install -y vim curl
wget https://dev.mysql.com/get/mysql-apt-config_0.8.10-1_all.deb
sudo -E dpkg -i mysql-apt-config_0.8.10-1_all.deb
sudo apt-get update

# Install MySQL 8
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password root'
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo -E apt-get -y install mysql-server

# Override any existing bind-address to be 0.0.0.0 to accept connections from host
sudo sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
echo "bind-address=0.0.0.0" | sudo tee -a /etc/mysql/my.cnf
echo "default-time-zone='+00:00'" | sudo tee -a /etc/mysql/my.cnf

# Isn't this done above???
mysql -u root -proot -e "CREATE USER 'root'@'%' IDENTIFIED BY 'root'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES; SET GLOBAL max_connect_errors=10000;"

# Start MySQL server
sudo /etc/init.d/mysql restart
