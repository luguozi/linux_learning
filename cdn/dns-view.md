CDN:
 CDN 阿里云，腾讯云，百度云 AWS
     网宿，蓝讯
 
CDN的全称是内容分发网络（Content Delivery Network),其设计目的是通过在现有的Internet中增加一层新的网络架构，将网站的内容发布到最接近用户的网络“边缘”，使用户可以就近取得所需的内容，提高用户访问网站的响应速度。 CDN有别于镜像，因为它比镜像更智能，或者可以做这样一个比喻：CDN=更智能的镜像+缓存+流量导流。因而，CDN可以明显提高Internet网络中信息流动的效率。从技术上全面解决由于网络带宽小、用户访问量大、网点分布不均等问题，提高用户访问网站的响应速度。

++++++++++++++++++++++++++++++++++++
注册/组用，阿里云服务器 （1-2台）
++++++++++++++++++++++++++++++++++++
1 将实验内容，推送公网演示
2 学习技术（文档/帮助）



----------------------------------------------------------------

# DNS-VIEW#  DNS视图 （智能DNS）

 正向解析: 域名解析IP地址
 反向解析: IP地址解析为域名

 第归查询  询问一次得到结果（缓存服务器DNS）  C/S
 迭代查询  询问多次得到结构 （服务器与服务器之间交流） S/S

 根域
 一级域名(国家域|顶级域)
      com org edu net cc cn us ja ko 
 二级域名 (内部搭建|租用)  
          baidu.com  uplooking.com
 三级域名 (内部分类【CNAME映射】)
         a.shifen.com



工作原理（一次第归，多次迭代）
13台根域 (10台设置在美国，英国、瑞典和日本) 


++++++++++++++++查询逻辑+++++++++++
 1 询问/etc/hosts
 2 询问nameserver (首选DNS，备用DNS)
 3 根域.
 4 一级域名 com.
 5 二级域名 qq.com.
 6 qq.com.(A记录/PTR记录) 
+++++++++++++++++++++++++++++++++



bind软件简介
一个bind，一个bind-chroot。有chroot环境之后，可以将所有bind 程序和配置都在/var/named/chroot目录下。


[root@servera ~]# yum -y install bind


bind9的view视图
--从Bind 9开始，bind支持视图功能。什么是视图呢？就是以某种特殊的方式根据用户来源的不同而返回不同的查询结果。这个技术在CDN中应用相当多，也是解决目前区域间带宽小和延迟大问题的一种方法。


语法:
view “名称” {  # 名称可以自拟，但必须唯一
    match-clients { ip/netmask; }; # 通过match-clients字段来区分不同区域
    zone "domain" IN {  # 当有了view字段之后，所有的zone定义字段必须出现在view字段当中
    type master;
    file "domain.zone";
    };
};


解析的主机名称：www.abc.com
电信客户端ip：172.25.0.11   希望其解析到结果为192.168.11.1
网通客户端ip：172.25.0.12   希望其解析到结果为22.21.1.1
其余剩下其他运营商的客户端解析的结果皆为1.1.1.1

配置：

---------------------------------------------------
[root@servera ~]# cat /etc/named.conf  |grep -v  ^# |grep -v ^$
options {
    listen-on port 53 { 127.0.0.1; any; };
    directory   "/var/named";
    dump-file   "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query     { localhost; any; };
    recursion yes;
    dnssec-enable no;
    dnssec-validation no;
    dnssec-lookaside auto;
    bindkeys-file "/etc/named.iscdlv.key";
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
view "dxclient" {
        match-clients { 172.25.1.11; };
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type master;
                file "dx.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
view "wtclient" {
        match-clients { 172.25.1.12; };
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type master;
                file "wt.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
view "other" {
        match-clients { any;};
         zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type master;
                file "other.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
include "/etc/named.root.key";
-----------------------------------------------------------


[root@servera ~]# cd /var/named/
[root@servera named]# vim dx.abc.com.zone 
$TTL 1D
@       IN SOA  ns1.abc.com. nsmail.abc.com. (
                                        10       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       NS      ns1.abc.com.
ns1     A       172.25.1.10
www     A       192.168.11.1




----------------------------------------------------
[root@servera named]# vim wt.abc.com.zone 

$TTL 1D
@       IN SOA  ns1.abc.com. nsmail.abc.com. (
                                        10       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       NS      ns1.abc.com.
ns1     A       172.25.1.10
www     A       22.21.1.1



-----------------------------------------------------
[root@servera named]# vim other.abc.com.zone 

$TTL 1D
@       IN SOA  ns1.abc.com. nsmail.abc.com. (
                                        10       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       NS      ns1.abc.com.
ns1     A       172.25.1.10
www     A       1.1.1.1

[root@servera named]# chgrp named wt.abc.com.zone dx.abc.com.zone other.abc.com.zone 

[root@servera named]# service named start
[root@servera named]# chkconfig named on


--------------------------
[root@serverb ~]# nslookup 
> server 172.25.0.10
Default server: 172.25.0.10
Address: 172.25.0.10#53
> www.abc.com
Server:     172.25.0.10
Address:    172.25.0.10#53

Name:   www.abc.com
Address: 192.168.11.1
----
[root@serverc ~]# nslookup
> server 172.25.0.10
Default server: 172.25.0.10
Address: 172.25.0.10#53
> www.abc.com
Server:     172.25.0.10
Address:    172.25.0.10#53

Name:   www.abc.com
Address: 22.21.1.1

----------------------------------------------------------------------------



ACL列表

举例：
目前电信的客户端为172.25.0.11和172.25.0.12这两台服务器
目前网通的客户端为172.25.0.13和172.25.0.14这两台服务器


[root@servera named]# vim /etc/named.conf 
include "/etc/dx.cfg";
include "/etc/wt.cfg";


view "dxclient" {
        match-clients { dx; };
};


view "wtclient" {
        match-clients { wt; };
};



[root@servera named]# vim /etc/dx.cfg
acl "dx" {
        172.25.1.11;
        172.25.1.12;
    172.25.1.0/24;
};



acl "wt" {
        172.25.0.13;
        172.25.0.14;
    192.168.1.0/24;
};

[root@servera named]# service named restart





+++++++++++++++++++++++++++++++++

[root@servera ~]# awk -F',' 'BEGIN {print "acl dx {"} ; $0 ~ /CHINANET/ {print $1"/"$2";"}; END {print "};"}' ipinfo.out   >> /etc/cn_dx.acl

grep -v '^[A-Z]' /etc/cn_dx.acl  |tee  /etc/cn_dx.acl



[root@servera ~]# awk -F',' 'BEGIN {print "acl wt {"} ; $0 !~ /CHINANET/ {print $1"/"$2";"}; END {print "};"}' ipinfo.out   >> /etc/cn_wt.acl
grep -v '^[A-Z]' /etc/cn_wt.acl  |tee /etc/cn_wt.acl
+++++++++++++++++++++++++++++++++



-----------------------------------------
拒绝某一个主机

acl badnet {
172.25.1.15;
};
options {
    blackhole  {badnet;};
};
-------------------------------------------


++++++++
主从DNS
++++++++
 (负载均衡,高可用)
 同步zone文件系统


## 5.基于dns-view的主辅同步##
由于一个IP地址只能读取一个view字段的配置，那想要同步多个view字段的内容就需要有不同的ip地址。
实验环境里，我们以serverj作为我们的dns从服务器，servera作为我们的dns主服务器

ip地址对应关系如下：
| servera           | serverj           |
| ----------------- | ----------------- |
| eth0:172.25.1.10  | eth0:172.25.1.19  |  ---电信
| eth1:192.168.0.10 | eth1:192.168.0.19 |  ---网通
| eth2:192.168.1.10 | eth2:192.168.1.19 |  ---其它

1）配置主服务器，将从属服务器的ip地址放入相应的视图区域配置中。


[root@servera ~]# cat /etc/named.conf |grep -v ^$

view "dxclient" {
        match-clients { dx; 172.25.1.19; !192.168.0.19; !192.168.1.19; };
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type master;
                file "dx.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
view "wtclient" {
        match-clients { wt; !172.25.1.19; 192.168.0.19; !192.168.1.19;};
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type master;
                file "wt.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
view "other" {
        match-clients { any; !172.25.1.19; !192.168.0.19; 192.168.1.19; };
         zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type master;
                file "other.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
include "/etc/named.root.key";




2）配置从服务器

先安装bind
[root@foundation1 ~]# rht-vmctl start serverj

[root@serverj ~]# yum -y install bind

将配置文件从servera迁移至serverj：
[root@servera ~]# tar -czf /tmp/conf.tgz /etc/named.conf /etc/dx.cfg /etc/wt.cfg[root@servera ~]# scp /tmp/conf.tgz serverj1:/tmp/

[root@serverj ~]# tar xf /tmp/conf.tgz  -C /
---------------------------------------------------------------
[root@serverj ~]# cat /etc/named.conf |grep -v ^$
include "/etc/dx.cfg";
include "/etc/wt.cfg";
options {
    listen-on port 53 { 127.0.0.1; any; };
    directory   "/var/named";
    dump-file   "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query     { localhost; any; };
    recursion yes;
    dnssec-enable no;
    dnssec-validation no;
    dnssec-lookaside auto;
    bindkeys-file "/etc/named.iscdlv.key";
    managed-keys-directory "/var/named/dynamic";
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
view "dxclient" {
        match-clients { dx; 172.25.1.19; !192.168.0.19; !192.168.1.19; };
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type slave;
        masters { 172.25.1.10; };
                file "slaves/dx.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
view "wtclient" {
        match-clients { wt; !172.25.1.19; 192.168.0.19; !192.168.1.19;};
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type slave;
        masters { 192.168.0.10; };
                file "slaves/wt.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
view "other" {
        match-clients { any; !172.25.1.19; !192.168.0.19; 192.168.1.19; };
         zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type slave;
                masters { 192.168.1.10; };
                file "slaves/other.abc.com.zone";
        };
include "/etc/named.rfc1912.zones";
};
include "/etc/named.root.key";
------------------------------------------------------------------



[root@serverj ~]# service named start
Redirecting to /bin/systemctl start  named.service
[root@serverj ~]# ls /var/named/slaves/
dx.abc.com.zone  other.abc.com.zone  wt.abc.com.zone





权威应答: 直接查询DNS服务器的记录
非权威应答: 间接（代理）查询DNS服务器的记录   --子域委派

  ns1.uplooking.com --->  ns1.gz.uplooking.com(A)
                    --->  ns1.sh.uplooking.com(A)



 uplooking.com --->
Non-authoritative answer:
        uplooking.com   nameserver = dns8.hichina.com.(北方)
                    dns8.hichina.com    internet address = 140.205.41.14 (A)
                    dns8.hichina.com    internet address = 140.205.81.24 (A)
                    dns8.hichina.com    internet address = 140.205.81.14
                    dns8.hichina.com    internet address = 106.11.211.64
                    dns8.hichina.com    internet address = 106.11.211.54
                    dns8.hichina.com    internet address = 106.11.141.124
                    dns8.hichina.com    internet address = 106.11.141.114
                    dns8.hichina.com    internet address = 140.205.41.24

        uplooking.com   nameserver = dns7.hichina.com.


根域(.)
 --> 一级域名(com.)
   --> 二级域名(hichina.com)
       --->  供应商 hichina.com
[(父域)uplooking.com ]供应商 hichina.com  ----> 子域（dns8.hichina.com.|dns7.hichina.com）
                               | 多台服务器


