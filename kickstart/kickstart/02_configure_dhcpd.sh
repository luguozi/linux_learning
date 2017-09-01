#!/bin/bash
IP=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2)
NET=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $4}'|cut -d ":" -f 2)
A=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2|cut -d '.' -f 1)
B=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2|cut -d '.' -f 2)
C=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2|cut -d '.' -f 3)
D=$(ifconfig eth1 | grep inet.*B|awk '/:/{print $2}'|cut -d ":" -f 2|cut -d '.' -f 4)


yum -y install dhcp &> /dev/null

cat > /etc/dhcp/dhcpd.conf << EOT
allow booting;
allow bootp;

option domain-name "pxe.luguozi.com";
option domain-name-servers $IP;
default-lease-time 600;
max-lease-time 7200;
log-facility local7;

subnet $A.$B.$C.0 netmask $NET {
  range $A.$B.$C.50 $A.$B.$C.60;
  option domain-name-servers $IP;
  option domain-name "pxe.luguozi.com";
  option routers $A.$B.$C.254;
  option broadcast-address $A.$B.$C.255;
  default-lease-time 600;
  max-lease-time 7200;
  next-server $IP;
  filename "pxelinux.0";
}

class "foo" {
  match if substring (option vendor-class-identifier, 0, 4) = "SUNW";
}

shared-network 224-29 {
  subnet 10.17.224.0 netmask 255.255.255.0 {
    option routers rtr-224.example.org;
  }
  subnet 10.0.29.0 netmask 255.255.255.0 {
    option routers rtr-29.example.org;
  }
  pool {
    allow members of "foo";
    range 10.17.224.10 10.17.224.250;
  }
  pool {
    deny members of "foo";
    range 10.0.29.10 10.0.29.230;
  }
}
EOT
service dhcpd restart
echo "success install dhcp server." 
chkconfig dhcpd on
