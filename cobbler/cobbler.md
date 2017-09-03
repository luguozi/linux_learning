
##1 配置cobbler

1> 下载软件


scp cobbler_soft.tar.gz root@172.16.250.206:/tmp
[root@localhost tmp]# tar -xf cobbler_soft.tar.gz

[root@localhost cobbler_soft]# iptables -F
[root@localhost cobbler_soft]# setenforce 0


2> 安装软件
[root@node1 cobbler_soft]# rpm -ivh libyaml-0.1.4-2.3.x86_64.rpm 
[root@node1 cobbler_soft]# rpm -ivh PyYAML-3.10-3.1.el6.x86_64.rpm 
[root@node1 cobbler_soft]# yum localinstall koan-2.6.9-1.el6.noarch.rpm 
[root@node1 cobbler_soft]# rpm -ivh Django14-1.4.20-1.el6.noarch.rpm 
[root@node1 cobbler_soft]# yum -y localinstall cobbler-2.6.3-1.el6.noarch.rpm
[root@node1 cobbler_soft]# yum localinstall cobbler-web-2.6.3-1.el6.noarch.rpm 


3> 基本配置

[root@node1 cobbler_soft]# service cobblerd restart
[root@node1 cobbler_soft]# chkconfig cobblerd on
[root@node1 ~]# cobbler check


The following are potential configuration items that you may want to fix:

1 : The 'server' field in /etc/cobbler/settings must be set to something other than localhost, or kickstarting features will not work.  This should be a resolvable hostname or IP for the boot server as reachable by all machines that will use it.
2 : For PXE to be functional, the 'next_server' field in /etc/cobbler/settings must be set to something other than 127.0.0.1, and should match the IP of the boot server on the PXE network.
3 : SELinux is enabled. Please review the following wiki page for details on ensuring cobbler works correctly in your SELinux environment:
    https://github.com/cobbler/cobbler/wiki/Selinux
4 : some network boot-loaders are missing from /var/lib/cobbler/loaders, you may run 'cobbler get-loaders' to download them, or, if you only want to handle x86/x86_64 netbooting, you may ensure that you have installed a *recent* version of the syslinux package installed and can ignore this message entirely.  Files in this directory, should you want to support all architectures, should include pxelinux.0, menu.c32, elilo.efi, and yaboot. The 'cobbler get-loaders' command is the easiest way to resolve these requirements.
5 : change 'disable' to 'no' in /etc/xinetd.d/rsync
6 : since iptables may be running, ensure 69, 80/443, and 25151 are unblocked
7 : debmirror package is not installed, it will be required to manage debian deployments and repositories
8 : ksvalidator was not found, install pykickstart
9 : The default password used by the sample templates for newly installed machines (default_password_crypted in /etc/cobbler/settings) is still set to 'cobbler' and should be changed, try: "openssl passwd -1 -salt 'random-phrase-here' 'your-password-here'" to generate new one
10 : fencing tools were not found, and are required to use the (optional) power management features. install cman or fence-agents to use them

Restart cobblerd and then run 'cobbler sync' to apply changes.



1>
```
[root@node1 cobbler_soft]# vim /etc/cobbler/settings

server: 192.168.0.1
或者：
[root@node1 cobbler_soft]#sed -i '/^server:/c server: \t 172.16.10.2' /etc/cobbler/settings

```
2>
```
[root@node1 cobbler_soft]# vim /etc/cobbler/settings
next_server: 192.168.0.1
或者：
[root@localhost tmp]sed -i '/^next_server:/c next_server: \t 172.16.10.2' /etc/cobbler/settings
```


3> 
[root@node1 cobbler_soft]# setenforce 0

4> 
[root@node1 cobbler_soft]# yum -y install syslinux


5>
[root@node1 cobbler_soft]# yum -y install rsync xinetd
[root@node1 cobbler_soft]# chkconfig tftp on
[root@node1 cobbler_soft]# service xinetd start
[root@node1 cobbler_soft]# chkconfig xinetd on


6>
[root@node1 cobbler_soft]# iptables -F


7>
省略

8>
[root@node1 cobbler_soft]# yum -y install pykickstart


9>
[root@node1 cobbler_soft]# openssl passwd -1 -salt 'random-phrase-here' 'redhat'
$1$random-p$MvGDzDfse5HkTwXB2OLNb.

default_password_crypted: "$1$random-p$MvGDzDfse5HkTwXB2OLNb."

lugz88
$1$random-p$EzdrrbPoUkh61Vg28mD3e1


[root@node1 ~]# vim /etc/cobbler/settings 
default_password_crypted: "$1$random-p$MvGDzDfse5HkTwXB2OLNb."

sed -i '/^default_password/c default_password_crypted: \t "$1$random-p$MvGDzDfse5HkTwXB2OLNb."' /etc/cobbler/settings


10>
fencing tools （电源设备） 
[root@node1 cobbler_soft]# yum install fence-agents

4 导入镜像
以下是相关配置路径(默认安装) :

Cobbler 配置主要位置：/var/lib/cobbler/
snippets 代码  位置：/var/lib/cobbler/snippets/
Kickstart 模板  位置 : /var/lib/cobbler/kickstarts/
默认使用的ks文件: /var/lib/cobbler/kickstarts/default.ks
安装源镜像       位置 : /var/www/cobbler/ks_mirror/ 



/etc/cobbler/settings cobbler主配置文件

/etc/cobbler/iso/ iso模板配置文件

/etc/cobbler/pxe pxe模板文件

/etc/cobbler/power 电源的配置文件

/etc/cobbler/users.conf Web 服务授权配置文件

/etc/cobbler/users.digest 用于web访问的用户名密码配置文件

/etc/cobbler/dhcp.template DHCP服务的配置模板

/etc/cobbler/dnsmasq.template DNS服务的配置模板

/etc/cobbler/tftpd.template tftp服务的配置模板

/etc/cobbler/modules.conf Cobbler模块配置文件



/var/lib/cobbler/config/ 用于存放distros、systems、profiles等信息配置文件

/var/lib/cobbler/triggers 用于存放用户定义的cobbler 命令

/var/lib/cobbler/kickstarts/ 默认存放kickstart文件
sample_end.ks

/var/lib/cobbler/loaders 存放的各种引导程序



********************
[root@localhost network-scripts]# vi /etc/sysconfig/selinux
SELINUX=disabled

[root@localhost network-scripts]# iptables -F
[root@localhost network-scripts]# setenforce 0


[root@localhost ~]# vi /etc/xinetd.d/rsync
disable = no


[root@localhost cobbler]# cobbler import --path=/yum --name=rhel-server-6.5-x86_64 --arch=x86_64

...
*** TASK COMPLETE ***

*****************

5 修改dhcp，让cobbler来管理dhcp，并进行cobbler配置同步

[root@node1 cobbler_soft]# yum -y install dhcp
[root@node1 cobbler_soft]# vim /etc/cobbler/dhcp.template 

subnet 192.168.0.0 netmask 255.255.255.0 {
     option routers             192.168.0.254;
     option domain-name-servers 192.168.0.254;
     option subnet-mask         255.255.255.0;
     range dynamic-bootp        192.168.0.100 192.168.0.110;
     default-lease-time         21600;
     max-lease-time             43200;
     next-server                172.16.10.2;
     class "pxeclients" {
          match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
          if option pxe-system-type = 00:02 {
                  filename "ia64/elilo.efi";
          } else if option pxe-system-type = 00:06 {
                  filename "grub/grub-x86.efi";
          } else if option pxe-system-type = 00:07 {
                  filename "grub/grub-x86_64.efi";
          } else {
                  filename "pxelinux.0";
          }
     }

}



[root@node1 cobbler_soft]#  vim /etc/cobbler/settings
manage_dhcp: 1


[root@node1 cobbler_soft]# /etc/init.d/cobblerd restart

[root@node1 cobbler_soft]# cobbler sync
*** TASK COMPLETE ***


测试验证：新建一个vmnet1网段（因为我前面配置的是这个网段）的虚拟机，然后启动，会出现cobbler的引导安装界面，选择并自动安装


## 补充1 cobbler的web管理


补充1：
cobbler的web管理


web管理路径 
# /etc/init.d/httpd restart   --先最好重启一下httpd服务
重启时如果报443端口被占用，解决方法:
# /etc/init.d/vmware-workstation-server stop
# chkconfig vmware-workstation-server off



然后通过firefox访问下面的路径
http://IP/cobbler_web       --默认用户名cobbler,密码cobbler


# htdigest /etc/cobbler/users.digest "Cobbler" abc  --增加一个abc用户
Adding user abc in realm Cobbler
New password: 
Re-type new password: 

# cat /etc/cobbler/users.digest 
cobbler:Cobbler:a2d6bae81669d707b72c0bd9806e01f3
abc:Cobbler:de5b9d396aa51c6710e62e555a2986ec


=============================================================

补充二:
关于cobbler使用ks文件的讨论


# cobbler distro list
   rhel-server-6.5-x86_64


设置profile(理解为在服务器端对每一个安装镜像做角色分类，如安装名与ks文件的关联）
distro代表导入的镜像
profile代表安装方案。一个distro可以对应一个或多个profile


# cobbler profile help  --查看帮助
=====
cobbler profile add
cobbler profile copy
cobbler profile dumpvars
cobbler profile edit
cobbler profile find
cobbler profile getks
cobbler profile list
cobbler profile remove
cobbler profile rename
cobbler profile report



# cobbler profile list  --查看有哪些profile，默认会有一个和先前导入镜像同名的profile
   rhel-server-6.5-x86_64

[root@localhost tmp]# cp /var/lib/cobbler/kickstarts/sample_end.ks /ks/ks.cfg
[root@localhost ks]# ls /ks/ks.cfg
# cobbler profile report --name rhel-server-6.5-x86_64 |grep "^Kickstart" |head -1  --通过report报告查看名为rhel-server-6.5-x86_64的安装镜像默认使用的ks文件为/var/lib/cobbler/kickstarts/sample_end.ks
Kickstart                      : /var/lib/cobbler/kickstarts/sample_end.ks


# cobbler profile add --name=my_ks1 --distro=rhel-server-6.5-x86_64  --kickstart=/ks/ks.cfg   
--把名为rhel-server-6.5-x86_64的安装镜像再加一个名为my_ks1的安装profile，使用的是/ks/ks.cfg文件(这个文件可以从模版库里面复制)


# cobbler profile list      --经过上面的操作，最终我导入的rhel-server-6.5-x86_64镜像拥有两种安装方案（一个是同名的安装方案，使用/var/lib/cobbler/kickstarts/sample_end.ks自动安装文件；一个是刚自己加的安装方案名为my_ks1，使用/ks/ks.cfg自动安装文件）
   my_ks1
   rhel-server-6.5-x86_64

再次使用客户端去安装验证，会出现两种安装方案给你选择
cobbler profile add --name=my_ks1 --distro=rhel-server-6.5-x86_64 --kickstart=/ks/ks.cfg

对上面操作的扩展(仅供参考）
# cobbler profile edit --name=my_ks1 --kickstart=/ks/ks2.cfg   --将my_ks1这个profile修改一个新的ks文件
# cobbler profile remove --name=my_ks1  --删除my_ks1这个profile


接着可以对该ks文件进行编辑



=================================================================

补充三：
针对ks文件的修改的讨论
上面在补充二时提到，最好不要完全照搬kickstart使用的ks文件（因为你照搬过来后，很多功能和配置和cobbler不好连接）


以上面的名字为rhel-server-6.5-x86_64的profile使用的ks文件/var/lib/cobbler/kickstarts/sample_end.ks为例来实验ks文件的修改

vim /var/lib/cobbler/kickstarts/sample_end.ks
# kickstart template for Fedora 8 and later.
# (includes %end blocks)
# do not use with earlier distros

#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Use text mode install
text
# Firewall configuration
firewall --enabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot

#Root password
rootpw --iscrypted $default_password_crypted
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
# System timezone
timezone  America/New_York
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# Allow anaconda to partition the system as needed
part /boot --asprimary --fstype="ext4" --size=200
part swap --asprimary --fstype="swap" --size=2000
part / --asprimary --fstype="ext4" --grow --size=1           －－这里是把原来的一句autopart改成自己想要的分区形式（原来是分lvm，现在我定义了三个分区）


%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
$SNIPPET('func_install_if_enabled')
%end

%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
touch /root/123
touch /tmp/123      --在这里又加了两句安装后的脚本，touch了两个文件
%end


保存后，用客户端安装rhel-server-6.5-x86_64来进行测试，最后发现分区和上面修改的一致，并且/root/123和/tmp/123这两个文件也都存在，说明上面的修改成功



--总结：在生产环境，你可以按这种方式把cobbler的ks文件模版，按你的需求改成几种不同的方案，再使用补充2部分里讲的cobbler profile add把这些ks文件和安装镜像对应起来做成不同的profile



＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

补充4：
客户端使用koan与服务器的cobbler联系，实现自动重装系统

在客户端安装koan-2.6.9-1.el6.noarch.rpm软件包
[root@localhost cobbler_soft]# scp koan-2.6.9-1.el6.noarch.rpm  root@172.16.10.101:/tmp

# yum localinstall koan-2.6.9-1.el6.noarch.rpm  --因为cobbler可以自动帮你解决yum的配置，所以依赖性可以直接帮你解决


# koan --server=1.1.1.2 --list=profiles    --1.1.1.2为cobbler服务器IP，得到的结果和在cobbler服务器上cobbler profile list命令得到的结果一样
   my_ks1
   rhel-server-6.5-x86_64


＃ koan --replace-self --server=1.1.1.2 --profile=rhel-server-6.5-x86_64  --指定本客户端按照名为rhel-server-6.5-x86_64的profile重装系统

# reboot  --敲完上面的命令，使用reboot，就会重装了（没敲上面的命令那reboot就是重启）


=====================================================================


1.假设你的公司有各种linux的安装需求(rhel,centos,ubuntu,suse,debian等)
你现在要为公司设计所有的自动安装方案,怎么做?
采用多标签。



2.如何利用GitHub安装cobbler
https://github.com/cobbler/cobbler
