#!/bin/bash
IP=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2)

yum install -y  xinetd tftp-server &> /dev/null
sed -i '/disable/c \\tdisable \t \t= no' /etc/xinetd.d/tftp
service xinetd start 
chkconfig xinetd on

yum -y install syslinux &> /dev/null
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
mkdir /var/lib/tftpboot/pxelinux.cfg


cat > /var/lib/tftpboot/pxelinux.cfg/default << EOT

default vesamenu.c32
timeout 60
display boot.msg
menu background splash.jpg
menu title Welcome to Global Learning Services Setup!

label local
        menu label Boot from ^local drive
        menu default
        localhost 0xffff

label install
        menu label Install rhel6
        kernel vmlinuz
        append initrd=initrd.img ks=http://$IP/rhel6.cfg

EOT

cp /yum/isolinux/boot.msg /var/lib/tftpboot/
cp /yum/isolinux/vmlinuz /var/lib/tftpboot/
cp /yum/isolinux/vesamenu.c32 /var/lib/tftpboot/
cp /yum/isolinux/initrd.img /var/lib/tftpboot/
