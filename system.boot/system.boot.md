system.boot note


--------------------------------------------------------------------
系统启动过程:
 RHEL5  sysvinit  串行启动 init---> /etc/inittab 
 RHEL6  Upstart   并行启动 init--> /etc/inittab(only runlevel) + /etc/init/  
 RHEL7  systemd   更快的并行启动 

Sysvinit   : /etc/init.d/network  
 -->  service httpd restart

LSB initscripts  : /usr/lib/systemd/system/httpd.service

 --> systemctl restart  httpd.service



++++++++++++++RHEL5启动过程++++++++++++++++

 第一部分:
BIOS开机自检
读取HD(磁盘)
加载MBR（主引导记录）  存放磁盘的第一个扇区512字节           
   MBR(bootloader引导器+DPT分区表（4*16）+ 2校验)

第二部分: GRUB

 bootloader引导器 ---> grub stage1 (引导器) ---> stage2 (grub.conf) -->menu.lst
--> e2fs_stage1_5 ---> DPT

--> 挂载引导分区 root (hd0,0) = /dev/sda1



default=0  --默认从第一个title启动
timeout=5  --等待时间
splashimage=(hd0,0)/grub/splash.xpm.gz --背景图
hiddenmenu --菜单
title Red Hat Enterprise Linux Server (2.6.18-164.el5)  --标签名称
    root (hd0,0)  --挂载boot分区
    kernel /vmlinuz-2.6.18-164.el5 ro root=/dev/vol0/root rhgb quiet  --加载内核,只读挂载跟分区
    initrd /initrd-2.6.18-164.el5.img --临时操作系统


第三部分:  init (sysvinit)

init 挂接/etc/和/lib 
 读取 /etc/inittab  --> id:5:initdefault:
--> /etc/rc.d/rc.sysinit 初始化

--> mount /etc/fstab 挂载设备

--> /etc/rc.d/rcX.d  X=runlevel

---> /etc/rc.d/rcX.d/S  启动 /etc/rc.d/rcX.d/K 关闭

--> rc.local 最后一个脚本


--> 判断是否X   启动图形界面
x:5:respawn:/etc/X11/prefdm -nodaemon

++++++++++++++++++++++++++++++++++++++




RHEL6  区别 RHEL5

initrd--initramfs
/initramfs-2.6.32-279.el6.x86_64.img


第三部分:
 
 /etc/inittab --- runlevel  与 /etc/init/
System initialization is started by /etc/init/rcS.conf ---> /etc/rc.d/rc.sysinit
Individual runlevels are started by /etc/init/rc.conf  ---> /etc/rc.d/rcX.d
Ctrl-Alt-Delete is handled by /etc/init/control-alt-delete.conf
# Terminal gettys are handled by /etc/init/tty.conf and /etc/init/serial.conf,



---------------------------------------------------------------------
 grub--grub2
 init--systemd






U盘系统

  了解系统的组成（重要的模块）
  修复故障的系统


如果能够进入当用户模式（第三部分以后故障【服务故障】）
用户模式无法进去 
   1 MBR丢失
   2 /boot目录丢失文件 
解决 1)  光盘自带Rescue模式 修复（救援）|（营救）模式
     2)  PXE增加Rescue标签
label rescue
  menu label ^Rescue installed system
  kernel vmlinuz
  append initrd=initrd.img rescue
     3) U盘系统


系统组成:
  内核、文件系统、SHELL、应用程序



U盘系统部署:

  1> 准备U盘 分区，格式化，设置为引导分区
卸载分区：
[root@i ~]# umount /media/*
[root@i ~]# fdisk -l /dev/sdb
[root@i ~]# dd if=/dev/zero of=/dev/sdb bs=500 count=1


[root@i ~]# fdisk -cu /dev/sdb

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First sector (2048-62980095, default 2048): 
Using default value 2048
Last sector, +sectors or +size{K,M,G} (2048-62980095, default 62980095): +8G

Command (m for help): a
Partition number (1-4): 1

Command (m for help): p

Disk /dev/sdb: 32.2 GB, 32245809152 bytes
64 heads, 32 sectors/track, 30752 cylinders, total 62980096 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1   *        2048    16779263     8388608   83  Linux

Command (m for help): w

[root@i ~]# mkfs.ext4 /dev/sdb1

[root@i ~]# mkdir /mnt/usb
[root@i ~]# mount /dev/sdb1  /mnt/usb/
[root@i ~]# df -h |grep mnt
/dev/sdb1             7.9G  146M  7.4G   2% /mnt/usb




2> 安装文件系统与BASH程序，重要命令（工具）、基础服务
[root@i ~]# rpm -qf /
filesystem-2.4.30-3.el6.x86_64
[root@i ~]# rpm -qf /bin/bash
bash-4.1.2-9.el6_2.x86_64
[root@i ~]# rpm -qf /bin/ls
coreutils-8.4-19.el6.x86_64
[root@i ~]# rpm -qf /bin/mkdir
coreutils-8.4-19.el6.x86_64
[root@i ~]# rpm -qf `which passwd`
passwd-0.77-4.el6_2.2.x86_64
[root@i ~]# rpm -qf `which useradd`
shadow-utils-4.1.4.2-13.el6.x86_64


[root@i ~]# mkdir -p /dev/shm/usb

[root@i ~]# yum -y install filesystem bash coreutils passwd shadow-utils openssh-clients rpm yum net-tools bind-utils vim-enhanced findutils lvm2 util-linux-ng --installroot=/dev/shm/usb/

[root@i ~]# cp -arv /dev/shm/usb/* /mnt/usb/



3> 安装内核
[root@i ~]# cp /boot/vmlinuz-2.6.32-279.el6.x86_64  /mnt/usb/boot/
[root@i ~]# cp /boot/initramfs-2.6.32-279.el6.x86_64.img  /mnt/usb/boot/
[root@i ~]# cp -arv /lib/modules/2.6.32-279.el6.x86_64/  /mnt/usb/lib/modules/



4> 安装GRUB程序
[root@i ~]# rpm -ivh ftp://192.168.0.254/notes/project/software/grub-0.97-77.el6.x86_64.rpm --root=/mnt/usb/ --nodeps --force


安装驱动:
[root@i ~]# grub-install --root-directory=/mnt/usb/  --recheck  /dev/sdb
grep: /mnt/usb//boot/grub/device.map: No such file or directory
mv: cannot stat `/mnt/usb//boot/grub/device.map': No such file or directory
Probing devices to guess BIOS drives. This may take a long time.
Installation finished. No error reported.  --安装完成，没有错误报告
This is the contents of the device map /mnt/usb//boot/grub/device.map.
Check if this is correct or not. If any of the lines is incorrect,
fix it and re-run the script `grub-install'.

(fd0)   /dev/fd0
(hd0)   /dev/sda
(hd1)   /dev/sdb
[root@i ~]# ls /mnt/usb/boot/grub/
device.map     fat_stage1_5  iso9660_stage1_5  minix_stage1_5     stage1  ufs2_stage1_5    xfs_stage1_5
e2fs_stage1_5  ffs_stage1_5  jfs_stage1_5      reiserfs_stage1_5  stage2  vstafs_stage1_5


定义grub.conf
[root@i ~]# cp /boot/grub/grub.conf /mnt/usb/boot/grub/



[root@i ~]# blkid  /dev/sdb1 
/dev/sdb1: UUID="ef08a197-317c-4338-9a74-13dfc8cd653d" TYPE="ext4" 


[root@i ~]# vim /mnt/usb/boot/grub/grub.conf 
default=0
timeout=5
splashimage=/boot/grub/splash.xpm.gz
title My USB System from hugo
        root (hd0,0)
        kernel /boot/vmlinuz-2.6.32-279.el6.x86_64 ro root=UUID=ef08a197-317c-4338-9a74-13dfc8cd653d selinux=0
        initrd /boot/initramfs-2.6.32-279.el6.x86_64.img





完善环境变量与配置文件:

[root@i ~]# cp /etc/skel/.bash* /mnt/usb/root/
[root@i ~]# chroot /mnt/usb/
[root@i /]# exit
exit

网络：
[root@i ~]# vim /mnt/usb/etc/sysconfig/network
NETWORKING=yes
HOSTNAME=usb.hugo.org

[root@i ~]# cp /etc/sysconfig/network-scripts/ifcfg-eth0 /mnt/usb/etc/sysconfig/network-scripts/


[root@i ~]# /mnt/usb/etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
USERCTL=no
IPADDR=192.168.0.123
NETMASK=255.255.255.0
GATEWAY=192.168.0.254




[root@i ~]# vim /mnt/usb/etc/fstab
UUID="ef08a197-317c-4338-9a74-13dfc8cd653d" / ext4 defaults 0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0




[root@i ~]# grub-md5-crypt 
Password: 
Retype password: 
$1$ALjoQ/$Bq0UdANEQmBY6zF1VDEhA/

[root@i ~]# vim /mnt/usb/etc/shadow 
root:$1$ALjoQ/$Bq0UdANEQmBY6zF1VDEhA/:15422:0:99999:7:::


-------------------------

同步脏数据
[root@i ~]# sync
[root@i ~]# reboot


选择从U盘启动

 


++++++++++++++++++++++++++
 从网络引导 自动化安装系统（内存1G 磁盘50G）

菜单标签 "Troubleshoot-01"









