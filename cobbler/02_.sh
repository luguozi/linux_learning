IP=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2)

read -p "请输入password:" DEPA

DFPASS=$(openssl passwd -1 -salt 'random-phrase-here' $DEPA)

#提前下载好软件
#[root@localhost cobbler_soft]# ll
#total 6376
#-rw-r--r--. 1 501 games  623828 Apr  1  2016 cobbler-2.6.3-1.el6.noarch.rpm
#-rw-r--r--. 1 501 games  665005 Apr  1  2016 cobbler-2.6.9.tar.gz
#-rw-r--r--. 1 501 games  294116 Apr  1  2016 cobbler-web-2.6.3-1.el6.noarch.rpm
#-rw-r--r--. 1 501 games 4537064 Apr  1  2016 Django14-1.4.20-1.el6.noarch.rpm
#-rw-r--r--. 1 501 games  180792 Apr  1  2016 koan-2.6.9-1.el6.noarch.rpm
#-rw-r--r--. 1 501 games   52304 Apr  1  2016 libyaml-0.1.4-2.3.x86_64.rpm
#-rw-r--r--. 1 501 games  161204 Apr  1  2016 PyYAML-3.10-3.1.el6.x86_64.rpm

#关闭防火墙
iptables -F
setenforce 0

#安装软件
rpm -ivh libyaml-0.1.4-2.3.x86_64.rpm &> /dev/null
rpm -ivh PyYAML-3.10-3.1.el6.x86_64.rpm &> /dev/null
yum -y localinstall koan-2.6.9-1.el6.noarch.rpm &> /dev/null
rpm -ivh Django14-1.4.20-1.el6.noarch.rpm &> /dev/null
yum -y localinstall cobbler-2.6.3-1.el6.noarch.rpm &> /dev/null
yum -y localinstall cobbler-web-2.6.3-1.el6.noarch.rpm &> /dev/null

#配置cobbler

service cobblerd restart
chkconfig cobblerd on
cobbler check &> /dev/null
sed -i '/^server:/c server: \t $IP' /etc/cobbler/settings
sed -i '/^next_server:/c next_server: \t $IP' /etc/cobbler/settings
yum -y install syslinux &> /dev/null
yum -y install rsync xinetd &> /dev/null
chkconfig tftp on
service xinetd start
chkconfig xinetd on
setenforce 0
iptables -F
yum -y install pykickstart &> /dev/null
sed -i '/^default_password/c default_password_crypted: \t “$1$random-p$MvGDzDfse5HkTwXB2OLNb."' /etc/cobbler/settings

#电源设备
yum -y install fence-agents &> /dev/null
sed -i '/^SELINUX=/c SELINUX=disabled' /etc/sysconfig/selinux
sed -i '/disable/c \\tdisable\t\t= no' /etc/xinetd.d/rsync
service httpd restart
service cobblerd restart
service xinetd restart
