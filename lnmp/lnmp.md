
网段：172.16.11.0
网关：172.16.11.1
掩码：255.255.255.0

| 组件 | IP |hostname| 
|:---|:---:|:---:|
|lnmp.server.nginx|172.16.11.11|nginx|
|lnmp.server.php01|172.16.11.12|php01|
|lnmp.server.php02|172.16.11.13|php02|
|lnmp.server.nfs|172.16.11.14|nfs|
|lnmp.server.mysql|172.16.11.15|mysql|
|lnmp.server.memcached|172.16.11.16|memchecked|

![lnmp架构图](pic/lnmp.01.png)



### LNMP搭建过程###

**1.安装软件包**

	用户在访问过程中如果访问动态页面，apache 和nginx 本身都解释不了php 页面，需要调用相应的php 进程，apache 在调用过程中会使用的libphp5.so 的模块从而调用php进程进行页面语言处理，

	而对于nginx来说，所以需要安装额外程序来调用php进程，这类软件会被称为php的进程管理器。Php 进程管理器比较常见的有spawn-fcgi 和php-fpm。Spawn-cfgi 和php-fpm 相比，后者性能更高，但后者必须和php 程序版本完全一致，如果升级了php，那么php-fpm 程序也要做相应的版本升级。

本例中使用的spawn-fcgi 程序。

Php 进程管理器在lnmp 环境中的作用：

（1）监听端口，nginx 把请求交给php 管理器，php 管理器监听9000 端口

（2）调用和管理php 进程，管理程序去看你本地有没有php 命令，有的话调用起来，php 命令运行之后再去处理刚才收到的页面请求，处理php 请求。

以下命令安装了spawn-fcgi，php 程序、数据库程序和php 连接数据库的驱动。**

**安装php和spawn-fcgi插件**
```
lftp 172.25.254.250:/notes/weekend/UP200/UP200_nginx-master> mirror pkg/
[root@nginx tmp]# setenforce 0
[root@nginx tmp]# iptables -F
[root@nginx tmp]# rpm -ivh spawn-fcgi-1.6.3-5.el7.x86_64.rpm
[root@nginx tmp]# yum install php php-mysql mariadb-server -y
```

**安装nginx**
```
[root@nginx tmp]# sed -i '/^SELINUX/c SELINUX=disabled' /etc/selinux/config
[root@nginx tmp]# yum localinstall -y nginx-1.8.0-1.el7.ngx.x86_64.rpm
```
**查看nginx文件列表**
```
[root@nginx tmp]# rpm -ql nginx
/etc/logrotate.d/nginx
/etc/nginx
/etc/nginx/conf.d
/etc/nginx/conf.d/default.conf
/etc/nginx/conf.d/example_ssl.conf
/etc/nginx/fastcgi_params
/etc/nginx/koi-utf
/etc/nginx/koi-win
/etc/nginx/mime.types
/etc/nginx/nginx.conf
/etc/nginx/scgi_params
/etc/nginx/uwsgi_params
/etc/nginx/win-utf
/etc/sysconfig/nginx
/usr/lib/systemd/system/nginx.service
/usr/libexec/initscripts/legacy-actions/nginx
/usr/libexec/initscripts/legacy-actions/nginx/upgrade
/usr/sbin/nginx
/usr/share/nginx
/usr/share/nginx/html
/usr/share/nginx/html/50x.html
/usr/share/nginx/html/index.html
/var/cache/nginx
/var/log/nginx
```

**2.配置虚拟主机**
```
[root@nginx tmp]# cd /etc/nginx/conf.d/
[root@nginx conf.d]# cp default.conf www.bbs.com.conf
[root@nginx conf.d]# vi www.bbs.com.conf
server {
    listen       80;
    server_name  www.bbs.com;
    root  /usr/share/nginx/bbs.com;
    index index.php index.html index.htm;
    charset utf-8;
    access_log  /var/log/nginx/bbs.com.access.log  main;

location ~ \.php$ {
    fastcgi_pass 127.0.0.1:9000;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME /usr/share/nginx/bbs.com$fastcgi_script_name;
    include fastcgi_params;
   }
}


[root@nginx conf.d]# mkdir -p /usr/share/nginx/bbs.com
[root@nginx conf.d]# systemctl restart nginx.service
```

**3.配置spawn-fcg**
```
[root@nginx conf.d]# vi /etc/sysconfig/spawn-fcgi
OPTIONS="-u nginx -g nginx -p 9000 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"
[root@nginx conf.d]# systemctl start spawn-fcgi
[root@nginx conf.d]# systemctl enable spawn-fcgi
[root@nginx conf.d]# ls /etc/rc.d/rc3.d/
K50netconsole  S10network     S80spawn-fcgi  S97rhnsd
```
++++++++++++++++++++++++++LNMP部属完成++++++++++++++++++++++++++++++
```
[root@nginx conf.d]# cat /usr/share/nginx/bbs.com/test.php
<?php
  phpinfo();
?>
```

**4.数据库初始化**
```
[root@nginx conf.d]# systemctl enable mariadb.service
[root@nginx conf.d]# systemctl start mariadb.service
[root@nginx conf.d]# mysqladmin -u root password "uplooking"
```

**5.创建网站根目录相关**
```
➜  lnmp scp Discuz_X3.1_SC_UTF8.zip root@172.16.11.11:/tmp



[root@nginx conf.d]# cd /tmp/

[root@nginx tmp]# unzip Discuz_X3.1_SC_UTF8.zip
[root@nginx tmp]# cp -r upload/* /usr/share/nginx/bbs.com/
[root@nginx tmp]# chown nginx. /usr/share/nginx/bbs.com/ -R
```
**6.数据库授权**
```
[root@serverb tmp] mysql -uroot -puplooking
MariaDB [(none)]> grant all on bbs.* to runbbs@'localhost' identified by 'uplooking';

MariaDB [(none)]> flush privileges;
MariaDB [(none)]> exit
```

**7.客户端访问**

[root@workstation ~]# echo “172.25.0.11 www.bbs.com” >> /etc/hosts

![lnmp.02.png](pic/lnmp.02.png)
![lnmp.03.png](pic/lnmp.03.png)
![lnmp.03.png](pic/lnmp.04.png)
![lnmp.03.png](pic/lnmp.05.png)
![lnmp.03.png](pic/lnmp.06.png)
![lnmp.03.png](pic/lnmp.07.png)

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
### LNMP迁移过程###

一般情况下，迁移需要有一定思路，建议按照以下思路执行

① 程序的迁移

② 配置文件的迁移

③ 数据文件的迁移

④ 相应的地址变更

⑤ 权限相关

⑥ 其他


**1.数据库迁移**

通常情况下，同一台服务器中，数据库是优先最容易出现性能瓶颈的服务，所以我们先将数据库迁移出来，迁移至mysql这台服务器。

（1）迁移mariadb-server 程序

````shell
[root@mysql ~]# iptables -F
[root@mysql ~]# setenforce 0
[root@mysql ~]# yum -y install mariadb-server
````

（2）启动数据库服务

````shell
[root@mysql ~]# systemctl start mariadb
````

（3）将nginx（旧的数据库服务器）上的数据库导出备份到一个文件中

````shell
[root@nginx bbs.com]# mysqldump --all-databases -uroot -puplooking > /tmp/mariadb.all.sql
````

（4）将导出的文件拷贝至新的数据库服务器mysql

````shell
[root@nginx bbs.com]# scp /tmp/mariadb.all.sql 172.16.11.15:/tmp/
````

（5）在mysql 机器上将导出的数据库导入

````shell
[root@mysql ~]# mysql < /tmp/mariadb.all.sql
[root@mysql ~]# systemctl restart mariadb
````

（6）修改php 代码，将dbhost 改为新的数据库服务器

`````shell
[root@nginx bbs.com]# for i in $(find /usr/share/nginx/bbs.com/ -name '*.php')
> do grep -q "localhost" $i && echo $i
> done
/usr/share/nginx/bbs.com/config/config_global_default.php
/usr/share/nginx/bbs.com/config/config_ucenter_default.php
**/usr/share/nginx/bbs.com/config/config_global.php**
**/usr/share/nginx/bbs.com/config/config_ucenter.php**
/usr/share/nginx/bbs.com/install/include/install_lang.php
/usr/share/nginx/bbs.com/source/class/class_sphinx.php
/usr/share/nginx/bbs.com/source/language/lang_admincp.php
/usr/share/nginx/bbs.com/source/language/lang_admincp_searchindex.php
**/usr/share/nginx/bbs.com/uc_server/data/config.inc.php**
/usr/share/nginx/bbs.com/uc_server/install/lang.inc.php
/usr/share/nginx/bbs.com/uc_server/install/var.inc.php 

 ---更换数据库的IP地址: 注意，要把localhost修改成修改后的数据库的IP地址
(注意：只需修改****里面的)
`````

（7）授权。允许php 程序所在机器读取数据库中的内容。

````shell
[root@mysql ~]# echo "grant all on bbs.* to root@'172.25.0.11' identified by 'uplooking';" | mysql -uroot -puplooking
[root@mysql ~]# echo "grant all on bbs.* to root@'serverb.pod0.exmaple.com' identified by 'uplooking';" | mysql -uroot -puplooking
[root@mysql ~]# mysqladmin -uroot -puplooking flush-privileges

注意：bbs.* 为在安装的时候指定的数据库的名字。
````

**2.php迁移**

将nginx上的php迁移至php01

（1）安装php php-mysql spawn-fcgi 程序

````shell
[root@php01 ~]# iptables -F
[root@php01 ~]# setenforce 0
[root@php01 tmp]# yum -y install php php-mysql
[root@php01 tmp]# cd /tmp/
[root@php01 tmp]# rpm -ivh spawn-fcgi-1.6.3-5.el7.x86_64.rpm
````

（2）迁移配置文件。

````shell(注意nginx用户)
[root@php01 tmp]# vi /etc/sysconfig/spawn-fcgi
OPTIONS="-u 996 -g 994 -p 9000  -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"

````

（3）迁移数据文件

````shell
[root@nginx tmp]# tar cf /tmp/datafile.tar /usr/share/nginx/bbs.com
[root@nginx tmp]# scp /tmp/datafile.tar 172.16.11.12:/tmp
````

（4）地址变更：修改虚拟主机配置文件，访问php 的请求交给新的php 进程管理器所在机器做处理。

````shell
[root@nginx tmp]# vi /etc/nginx/conf.d/www.bbs.com.conf
location ~ .php$ {
	fastcgi_pass 172.16.11.12:9000;
	fastcgi_index index.php;
	fastcgi_param SCRIPT_FILENAME /usr/share/nginx/bbs.com$fastcgi_script_name;	
	include fastcgi_params;
}

````

（5）权限变更：

权限变更涉及到ugo权限以及数据库授权的操作

````shell
[root@nginx tmp]# id nginx
uid=996(nginx) gid=994(nginx) groups=994(nginx)
[root@php01 bbs.com]# groupadd -g 994 nginx
[root@php01 bbs.com]# useradd -u 996 -g 994 nginx
[root@php01 bbs.com]# tar xf /tmp/datafile.tar -C /
[root@php01 bbs.com]# chown nginx.nginx -R /usr/share/nginx/bbs.com/
[root@php01 bbs.com]# setenforce 0
[root@mysql ~]# echo "grant all on bbs.* to root@'172.16.11.12' identified by 'uplooking';" | mysql -uroot -puplooking
[root@mysql ~]# echo "grant all on bbs.* to root@'serverc.pod0.example.com' identified by 'uplooking';" | mysql -uroot -puplooking
[root@mysql ~]# mysqladmin -uroot -puplooking flush-privileges
````

（6）重启服务

````shell
[root@mysql ~]# systemctl restart mariadb
[root@nginx conf.d]# systemctl restart nginx.service
[root@nginx tmp]# systemctl stop spawn-fcgi.service
[root@php01 tmp]# systemctl restart spawn-fcgi.service
````


（7） 访问测试（略）


**3.PHP 程序复制**

通过程序拆分操作，每台服务器上已经只运行一个程序，但是可能还是不能够处理大量的用户请求，我们就可以使用程序
复制，也就是多台机器使用跑同一个程序，负载均衡。以php 程序复制为例。这里将开启第二台服务器php02作为第二胎php服务器。
（1）进入服务器公共目录，安装php 进程管理器spawn-fcfgi

````shell
[root@php02 ~]# iptables -F
[root@php02 ~]# setenforce 0
[root@php02 tmp]# rpm -ivh spawn-fcgi-1.6.3-5.el7.x86_64.rpm
````

（2）安装php 程序和php 连接mariadb 的驱动

````shell
[root@php02 tmp]# yum -y install php php-mysql
````

（3）将第一台cgi 服务器上的配置文件复制到第二台cgi 服务器上

````shell
[root@php01 tmp]# scp /etc/sysconfig/spawn-fcgi 172.16.11.13:/etc/sysconfig/
````

（4）将第一台cgi 服务器上的php 页面文件复制到第二台cgi 服务器上

````shell
[root@php01 tmp]# scp /tmp/datafile.tar 172.16.11.13:/tmp
[root@servere ~]# tar xf /tmp/data.tar -C /
````

（5）定义upsteam 字段，地址池中包含后台两台cgi 服务器，以便fastcgi_cgi 字段引用

```shell
[root@nginx discuz]# vi /etc/nginx/nginx.conf
upstream php_pools {
        server 172.16.11.12:9000;
        server 172.16.11.13:9000;
}
```

（6）php 文件的访问请求交给后台cgi 服务器

````shell
[root@nginx discuz]# vi /etc/nginx/conf.d/www.bbs.com.conf
location ~ .php$ {
	fastcgi_pass php_pools;
	fastcgi_index index.php;
	fastcgi_param SCRIPT_FILENAME /usr/share/nginx/bbs.com$fastcgi_script_name;
	include fastcgi_params;
}
````

（7）修改新的cgi 服务器上UGO 权限，保证nginx 用户对所有的php 文件有读写权限

````shell
[root@php02 bbs.com]# groupadd -g 994 nginx
[root@php02 bbs.com]# useradd -u 996 -g nginx nginx
[root@php02 bbs.com]# systemctl start spawn-fcgi.service
````

（8）数据库授权

````shell
[root@mysql ~]# echo "grant all on *.* to root@'172.16.11.13' identified by 'uplooking';" | mysql -uroot -puplooking

[root@mysql ~]# mysqladmin -uroot -puplooking flush-privileges
````

（9）客户端测试，两台cgi 服务器是否都能够正常工作。（略）

**4.共享存储问题**

如果后台是两台cgi 服务器，那么会存在数据一致性问题。比如，A 用户上传图片到论坛的请求经过轮询被提交到php01机器，那么这张图片就会被保存到php01机器，以后如果B 用户的请求被提交到php01 机器，那么B 用户可以访问下载该图片，但是如果用户C 请求经过轮询之后被提交到php02 机器，那么用户C 是不能浏览下载这张图片的，会出现报错（如图所示）。原因就是因为图片被上传到php01机器，php02 机器上没有这张图片。可通过共享存储来解决数据不一致的问题。

![7](pic/lnmp.08.png)
（1）nfs 作为共享存储服务器，安装上nfs_utils 和rpcbind 两个软件包（默认已安装）

````shell
[root@nfs ~]# yum -y install nfs-utils rpcbind
````

（2）将其中一台cgi 服务器上的php 页面文件拷贝至共享存储服务器。

````shell
[root@php01 ~]# tar cf /tmp/data1.tar /usr/share/nginx/bbs.com/
[root@php01 ~]# scp /tmp/data1.tar root@172.16.11.14:/tmp
[root@nfs tmp]# tar -xf /tmp/data1.tar -C /
````

（3）添加nginx 用户和组。

````shell
[root@serverj ～]# groupadd -g 994 nginx
[root@serverj ～]# useradd -u 996 -g nginx nginx
````

（4）配置nfs。

````shell
[root@nfs tmp]# vi /etc/exports
/usr/share/nginx/bbs.com        172.16.0.0/255.255.255.0(rw)
````

（5）启动rpc 服务和nfs 服务。

````shell
[root@nfs tmp]# systemctl start rpcbind
[root@nfs tmp]# systemctl restart nfs-server
````

（6）serverb、serverc 和servere 作为nfs 客户端去挂载共享存储服务器上共享出来的目录。（永久挂载写到/etc/fstab 文件）

````shell
[root@serverc ~]# mount 172.25.0.19:/usr/share/nginx/bbs.com /usr/share/nginx/bbs.com
[root@servere ~]# mount 172.25.0.19:/usr/share/nginx/bbs.com /usr/share/nginx/bbs.com
[root@serverb ~]# mount 172.25.0.19:/usr/share/nginx/bbs.com /usr/share/nginx/bbs.com
````

（7）客户端测试。再上传图片。（图略）



