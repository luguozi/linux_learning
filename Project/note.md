```
[root@serverj ~]# cat /etc/named.conf
//
// named.conf
//
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
// server as a caching only nameserver (as a localhost DNS resolver only).
//
// See /usr/share/doc/bind*/sample/ for example named configuration files.
//

options {
	listen-on port 53 { 127.0.0.1; any; };
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { localhost; any; };

	/*
	 - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
	 - If you are building a RECURSIVE (caching) DNS server, you need to enable
	   recursion.
	 - If your recursive DNS server has a public IP address, you MUST enable access
	   control to limit queries to your legitimate users. Failing to do so will
	   cause your server to become part of large scale DNS amplification
	   attacks. Implementing BCP38 within your network would greatly
	   reduce such attack surface
	*/
	recursion yes;

	dnssec-enable yes;
	dnssec-validation yes;
	dnssec-lookaside auto;

	/* Path to ISC DLV key */
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

view "php" {
	match-clients { 172.25.16.0/24; };
	zone "." IN {
		type hint;
		file "named.ca";
	};
 	zone "php-f16.com" IN {
                type master;
                file "php-f16.com.zone";
	};
include "/etc/named.rfc1912.zones";
};

view "jsp" {
        match-clients { 172.25.254.0/24; };
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "jsp-f16.com" IN {
                type master;
                file "jsp-f16.com.zone";
        };
include "/etc/named.rfc1912.zones";
};


zone "." IN {
	type hint;
	file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

```


```
[root@serverj ~]# cat /var/named/jsp-f16.com.zone
$TTL 1D
@       IN SOA  ns16.jsp-f16.com. nsmail.jsp-f16.com. (
                                        10       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       NS      ns16.jsp-f16.com.
ns16     A       172.25.254.16
www     A       172.25.1.12
www     A       172.25.1.13

```


```
[root@serverj ~]# cat /var/named/php-f16.com.zone
$TTL 1D
@       IN SOA  ns16.php-f16.com. nsmail.php-f16.com. (
                                        10       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       NS      ns16.php-f16.com.
ns16     A       172.25.254.16
www     A       172.25.16.10
www     A       172.25.16.11
```


