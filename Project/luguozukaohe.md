
servera nginx001


172.25.16.10/24-16.19


-----------------------------------
mysql/servsync 1台
nginx+php+memcache 2台
nginx+tomcat+memcache 2台
nginx反向代理 2台
squid反向代理 2台
DNS轮循 1台
-----------------------10台----------
servera : 172.25.16.10 : nginx+php:9000 ---001  OK 
serverb : 172.25.16.11 : nginx+php:9000 ---002  OK 还没配置智能解析

serverc : 172.25.16.12 : nginx+tomcat1+jdk   OK 
serverd : 172.25.16.13 : nginx+tomcat2+jdk   OK 

servere : 172.25.16.14 : squid1
serverf : 172.25.16.15 : squid2

serverg : 172.25.16.16 : memcached

serverh : 172.25.16.17 : nginx-L7     OK ————php -->a+b
serveri : 172.25.16.18 : nginx-L7     OK ————tomcat -->a+b

172.25.254.16 : 172.25.16.19 : F10/NAS+mysql+DNS



##参考说明

  主从复制/读写分类

          / master1(rw)  ---- slave1(r)
  dbproxy(读写分离)  
          \ master2(rw)  ---- slave2(r)


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
说明(思路)
 1) 搭建pxe批量安装系统(kvm克隆)
 2) 安装后端数据库实现mysql读写分离与主从复制(建议5台[1台])
 3) 安装servsync实现页面一致性的发布(NFS共享存储) 
 4) 安装nginx+php+memcache/redis(php论坛) www.php-fX.com  2台
 5) 安装nginx+tomcat+jdk+jsp+memcache(jsp企业网站) www.jsp-fX.com 2台
 6) 安装nginx反向代理服务器(调度器)实现负载均衡(轮循) 1台
 7) 安装squid或者varnish实现静态缓存加速（CDN）2台
 8) 安装nginx反向代理服务器(双机互备) 1台
 9) 通过DNS轮循访问2台nginx调度器 建议2台<DNS主从>  1台
10) 搭建openldap实现帐号集中制管理
11) 设计ssh服务(监听内网,使用密钥对登录,设置跳板机)
12) 设计防火墙规则,只允许公网访问http与ssh协议
13) 编写项目文档



