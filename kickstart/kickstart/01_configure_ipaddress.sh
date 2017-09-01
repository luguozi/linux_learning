#!/bin/bash

echo "/usr/sbin/setenforce 0" >> /etc/rc.local
echo "/sbin/iptables -F " >> /etc/rc.local
chmod +x /etc/rc.d/rc.local
source /etc/rc.local


read -p "请输入网卡名称，如eth0:" DEVICE

MACS=$(ifconfig $DEVICE | awk '/Ether/{print $5}')
IP=172.16.10.2
GW=172.16.10.254
NET=255.255.255.0
cat > /etc/sysconfig/network-scripts/ifcfg-$DEVICE << EOT
DEVICE=$DEVICE
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static
HWADDR=$MACS
IPADDR=$IP
GATEWAY=$GW
NETMASK=$NET
EOT

service network restart
hostname pxe.luguozi.com
echo "172.16.10.2 pxe.luguozi.com pxe" >> /etc/hosts
