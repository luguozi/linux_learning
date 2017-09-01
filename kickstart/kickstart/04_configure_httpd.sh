#!/bin/bash
IP=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2)
yum -y install httpd &> /dev/null
echo "u have success install httpd."
cp rhel6_base_ks.cfg /var/www/html/rhel6.cfg
chowm apache. /var/www/html/rhel6.cfg

#cp /var/lib/tftpboot/pxelinux.cfg/ks.cfg /var/www/html/myks.cfg
#chown apache. /var/www/html/myks.cfg
mkdir -p /var/www/html/ks_config/
cp 6optimization.sh /var/www/html/ks_config/6optimization.sh
chmod +x /var/www/html/ks_config/6optimization.sh
yum -y install elinks
service httpd restart
mkdir /var/www/html/dvd
echo "/dev/cdrom /var/www/html/dvd iso9660 loop,ro  0  0" >> /etc/fstab
mount -a
setenforce 0
