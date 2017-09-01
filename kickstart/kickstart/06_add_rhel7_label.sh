IP=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2)
cp rhel7_base_ks.cfg /var/www/html/rhel7.cfg
cp 7optimization.sh /var/www/html/ks_config/7optimization.sh
chmod +x /var/www/html/ks_config/7optimization.sh
mkdir -p /var/lib/tftpboot/rhel7u3
mkdir /var/www/html/rhel7 -p
#挂载光盘
mount -o loop /dev/cdrom1 /var/www/html/rhel7/
cd /var/www/html/rhel7/isolinux/
#复制rhel7的光盘的文件到目录下
cp vmlinuz initrd.img /var/lib/tftpboot/rhel7u3/

cat >> /var/lib/tftpboot/pxelinux.cfg/default << EOT

label install7
        menu label Install rhel7
        kernel rhel7u3/vmlinuz
        append initrd=rhel7u3/initrd.img ks=http://$IP/rhel7.cfg

EOT

