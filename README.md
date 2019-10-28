# arch squid sslbump

## sources

```txt
# good examples for sslbump
https://blog.microlinux.fr/squid-https-centos/

# explain peek and 
https://wiki.squid-cache.org/Features/SslPeekAndSplice

# how to bump modus
http://marek.helion.pl/install/squid.html

# crate white list and white ip list
https://docs.diladele.com/faq/squid/sslbump_squid_windows.html


# mikrotek router
https://docs.diladele.com/tutorials/mikrotik_transparent_squid/index.html


# QUIC protocol
https://wiki.squid-cache.org/KnowledgeBase/Block%20QUIC%20protocol

# https://unix.stackexchange.com/questions/58635/iptables-set-mark-route-diferent-ports-through-different-interfaces

# transparent proxy and allow direct
https://forum.netgate.com/topic/90185/nat-to-external-squid-proxy
http://tldp.org/HOWTO/TransparentProxy-6.html#ss6.1


# disable hostname and x header
https://wiki.alpinelinux.org/wiki/Setting_up_Explicit_Squid_Proxy

# http header check
https://redbot.org/?uri=https%3A%2F%2Fwww.heise.de


https://www.spinics.net/lists/squid/msg88986.html
# We want the query strings as well.
strip_query_terms off

# dns trace
https://www.netmeister.org/blog/dns-tcpdump.html


# protocol error
http://squid-web-proxy-cache.1019090.n4.nabble.com/Help-troubleshooting-proxy-lt-gt-client-https-td4682583.html

```

## create self signed certificate

```bash

PREPARE_SQUID_SSLBUMP_CERTIFICATE="prepare_squid_sslbump_certificate.sh"
cat << EOF | tee $PREPARE_SQUID_SSLBUMP_CERTIFICATE
#!/bin/bash

set -e

openssl req -new \
-newkey rsa:2048 \
-sha256 \
-nodes \
-days 3650 \
-x509 \
-extensions v3_ca \
-keyout \$(hostname).\$(hostname --fqdn).pem \
-out \$(hostname).\$(hostname --fqdn).pem \
-subj "/C=DE/ST=BAYERN/L=OTTOBRUNN/O=PROXY USED/OU=education/CN=mathias-stadler.de"

openssl x509 -in \$(hostname).\$(hostname --fqdn).pem -outform DER -out \$(hostname).\$(hostname --fqdn).der

# view certificate was create
 openssl x509 -in  \$(hostname).\$(hostname --fqdn).pem -text

EOF

bash +x $PREPARE_SQUID_SSLBUMP_CERTIFICATE

```

## log coloured

```bash

#!/bin/bash
tail -f /var/log/squid/* |sed --unbuffered -e 's/\(\\r\\n\).*/^M/'| sed G |sed --unbuffered  \
    -e 's/\(.*TCP_MEM_HIT.*\)/\o033[32m\1\o033[39m/' \
    -e 's/\(HIER_DIRECT\)/\o033[31m\1\o033[39m/' \
    -e 's/\(TCP_MISS\)/\o033[31m\1\o033[39m/' \
    -e 's/\(\\r\\n\)/\o033[31m\1\o033[39m/' \
    -e 's/\(\\r\\n\)/\\r\\n/' \
    -e 's/\(\(1\?[0-9][0-9]\?\|2[0-4][0-9]\|25[0-5]\)\.\)\{3\}\(1\?[0-9][0-9]\?\|2[0-4][0-9]\|25[0-5]\)/\o033[31m\0\o033[39m/' \
    -e 's@\(http[s]*://[a-zA-Z0-9.-]*[^ ]*\)@\o033[31m\0\o033[39m@' \

```

## match url

- we used the gnu sed version
- sed (GNU sed) 4.7

```bash
cat /tmp/t | sed -e 's@\(http[s]*://[a-zA-Z0-9.-]*[^ ]*\)@START=> \0 <= END  @'
```

## set term background of black

```bash
setterm -term linux -back black
```

## track url

<https://www.threatminer.org/about.php>

## squidgard

```txt
https://www.urlfilterdb.com/home.html
```

## clean iptables

```bash
#!/bin/bash

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -t nat -L -n
```

## set transparency proxy own server/instance

```bash
#!/bin/bash
gid=`id -g proxy`
IP_ETH0_ADDR=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
iptables -t nat -A OUTPUT -p tcp --dport 80 -m owner --gid-owner $gid -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 80 -j DNAT --to-destination $IP_ETH0_ADDR:3129
iptables -t nat -A OUTPUT -p tcp --dport 443 -m owner --gid-owner $gid -j ACCEPT
iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination $IP_ETH0_ADDR:3129
```

- 2nd version

```bash

#!/bin/bash

# your sslbump proxy listening port define in th squid.conf
SQUIDPORT=3129

# server ip og cache box
SQUIDIP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 80 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port $SQUIDPORT

iptables -t nat -A PREROUTING -s $SQUIDIP -p tcp --dport 443 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port $SQUIDPORT

iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -t mangle -A PREROUTING -p tcp --dport $SQUIDPORT -j DROP
```

## the rest

```txt
fs perfomance

http://blog.neu.edu.cn/elm/archives/99

```

## nftables

```txt
# homepage
https://wiki.nftables.org/wiki-nftables/index.php/Main_Page


# presentation slides from 2016
https://people.netfilter.org/pablo/nft-tutorial.pdf

https://wiki.archlinux.org/index.php/nftables#Installation

https://ungleich.ch/en-us/cms/blog/2018/09/19/introduction-to-nftables/

# arch nftables site
https://wiki.archlinux.org/index.php/nftables

# presentation slides from 2018
https://2018.pass-the-salt.org/files/talks/09-keynote-linux-firewalling.pdf

https://superuser.com/questions/1277697/making-routing-decisions-based-on-uid-using-nftables/1277966
```

## disable iptables

```bash
iptables -F
```

## prepare file for lod modules for iftables

```bash
cat << EOF | sudo tee /etc/modules-load.d/nftables.conf
nf_conntrack
nf_conntrack_ipv4
nf_conntrack_ipv6
nf_defrag_ipv4
nf_defrag_ipv6
nf_nat
nf_nat_ipv4
nf_tables
nf_tables_inet
nf_tables_ipv4
nf_tables_ipv6
nfnetlink
nft_counter
nft_ct
nft_hash
nft_limit
nft_log
nft_meta
nft_rbtree
nft_reject
nft_reject_inet
nft_reject_ipv4
nft_reject_ipv6
EOF

# reboot the system for clean load all modules
```

## list load modules

```bash
# all
lsmod
# nf* mudules // Modules name start with nf
lsmod |grep '^nf'
```

## check ruleset

```bash
nft list ruleset
```

## add table

```bash
# add table
nft add table foo
# list all tables
nft list tables
# list only table foo
nft list table ip foo
```

## add chain // hold rules

- The purpose of chains is to hold #Rules. Unlike chains in iptables, there are no built-in chains in nftables. This means that if no chain uses any types or hooks in the netfilter framework, packets that would flow through those chains will not be touched by nftables, unlike iptables.

- Chains have two types. A base chain is an entry point for packets from the networking stack, where a hook value is specified. A regular chain may be used as a jump target for better organization.

```bash
# create regular chain
nft add chain foo bar

```

## Base chain

- follow this schema

```txt
# nft add chain <table name> <new chain name> { type type hook hook priority priority \; }
  nft add chain foo input {type filter hook input priority 1 \;}
```

- family : For IPv4/IPv6/Inet address families hook can be prerouting, input, forward, output, or postrouting.

- priority : priority takes an integer value. Chains with lower numbers are processed first and can be negative

## list chain

```bash
# nft list chain < table name > < chain name >
nft list chain foo input
```

## delete chain complete with all rules

```bash
# nft delete chain <table name> <chain name>
nft delete chain foo input
```

## list of Base chain priority

```txt
https://wiki.nftables.org/wiki-nftables/index.php/Configuring_chains
```

## add rule to chain

```bash
# nft add rule ip <table name> <chain name> <rule ....>
nft add rule ip foo bar tcp dport != 80
```

## mark packet and reroute

```bash
nft delete table mangle
nft add table ip mangle
nft 'add chain ip mangle output {type route hook output priority -150; }'
nft add rule ip mangle output tcp dport 80 meta mark set 3
nft add rule ip mangle output tcp dport 443 meta mark set 3
nft list ruleset
```

## enable nftables service make rules reboot

- service is from type onshot so the service load the config ones at system start
- all other changes must you self handle

```bash
# write rules to /etc/nftables.conf
nft list ruleset >/etc/nftables.conf

# enable service installed with pacman -S nftables
systemctl enable nftables.service

```

## routing marked package

## source

```txt
# show routing priority
https://unix.stackexchange.com/questions/188584/which-order-is-the-route-table-analyzed-in

# delete and restore ip routing
https://serverfault.com/questions/345111/iptables-target-to-route-packet-to-specific-interface
```

## routing show priority

```bash
ip rule show
```

## routing show local

- The local table is the special routing table containing high priority control routes for local and broadcast addresses.

```bash
ip route show table local
```

## routing show main

- The main table is the normal routing table containing all non-policy routes. This is also the table you get to see if you simply execute ip route show (or ip ro for short).

```bash
ip route show table main
```

## remove routing table

```bash
# Flush ALL THE THINGS.
ip route flush table main
ip route flush table 11
ip rule flush
```

## restore routing table

```bash

# Restore the basic rules and add our own.
ip rule add lookup default priority 32767
ip rule add lookup main priority 32766



# Restore the main table.  
ip route add 127.0.0.0/8 via 127.0.0.1 dev lo
ip route add 192.168.178.0/24 dev enp0s25 proto kernel scope link src 192.168.178.38 metric 100
ip route add default via 192.168.178.1 dev enp0s25 proto dhcp metric 100

# Set up table 11.  I honestly don't know why 'default' won't work, or
# why the second line here is needed.  But it works this way.
ip rule add fwmark 3 priority 1000 table 11
ip route add 192.168.178.0/24 dev enp0s25 table 11
ip route add 192.168.178.0/24 via 192.168.178.250 dev enp0s25 table 11


ip route flush cache

```

```txt
https://mirrors.deepspace6.net/Linux+IPv6-HOWTO/x2561.html

```

## crt to pem

```bash
openssl x509 -in mycert.crt -out mycert.pem -outform PEM
```

Notice how the port details have changed from IPv4-only to IPv6-only.

You are using a split-stack OS where each of the IPv4 and IPv6 ports
needs separate TLS/SSL context. You can set the same settings and load
the same cert file, just have to place the config separately in
squid.conf for now:

https_port 0.0.0.0:3127 intercept ssl-bump \
  generate-host-certificates=on \
  dynamic_cert_mem_cache_size=16MB \
  cert=/etc/squid/ssl_cert/server1.crt

https_port [::]:3127 intercept ssl-bump \
  generate-host-certificates=on \
  dynamic_cert_mem_cache_size=16MB \
  cert=/etc/squid/ssl_cert/server1.crt

## from here
  
  <http://lists.squid-cache.org/pipermail/squid-users/2015-February/002275.html>

trust list |grep -i iden
    label: IdenTrust Commercial Root CA 1
    label: IdenTrust Public Sector Root CA 1

## verify LETSENCRIPT

https://community.letsencrypt.org/t/where-can-i-download-the-trusted-root-ca-certificates-for-lets-encrypt/33241

```bash
openssl s_client -connect www.wolkendoktor.de:443 -showcerts

wget "https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt" --output-document=letsencryptauthorityx3.pem

```

```bash
# SET SQUID AS REVERSE PROXY WITH AN SSL CERTIFICATE FROM A PUBLIC CA
https://www.ssl247.com/kb/ssl-certificates/install/squid

SQUIDURL="192.168.178.250"
# for accept routing for cache avoid loop
iptables -t mangle -A PREROUTING -j ACCEPT -p tcp --dport 80 -s $SQUIDURL
iptables -t mangle -A PREROUTING -j ACCEPT -p tcp --dport 443 -s $SQUIDURL
# for routing 80.443 traffic own process
iptables -t mangle -A OUTPUT -j MARK --set-mark 3 -p tcp --dport 80
iptables -t mangle -A OUTPUT -j MARK --set-mark 3 -p tcp --dport 443

iptables -L -t mangle
ip route add default via $SQUIDURL dev enp0s25  table 2
ip route show table 2
ip rule show
```

https://github.com/jsha/minica

## certbot private keys

```bash
https://superuser.com/questions/1194523/lets-encrypt-certbot-where-is-the-private-key
```

## add cert local to ubuntu

- add your certificat to /usr/local/share/ca-certificates and name it with a .crt file extension

- convert if necessary the cert from pem to crt
- from here : https://stackoverflow.com/questions/13732826/convert-pem-to-crt-and-key

```bash
openssl x509 -outform der -in myCA.pem -out myCA.crt
```

- update your master ca file /etc/ssl/certs/ca-certificates.crt

```bash
sudo update-ca-certificates
```

## git clone with squid

- found the missing certificate
- from here  <https://stackoverflow.com/questions/21181231/server-certificate-verification-failed-cafile-etc-ssl-certs-ca-certificates-c>

```bash

SCRIPT_NAME="getCertificateFromSide.sh"
cat << EOF >$SCRIPT_NAME
#!/bin/bash

if [ -z "\$1" ]
then
    echo "hostname missing"
    echo "USAGE: \${0##*/} <hostname>"
    exit 1
fi

hostname=\$1
port=443
trust_cert_file_location="\$(curl-config --ca)"

sudo bash -c "echo -n | openssl s_client -showcerts -connect $hostname:$port \
    2>/dev/null  | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | \
    tee -a \$trust_cert_file_location"

EOF

chmod +x $SCRIPT_NAME

```

## install acme

- socat is necessary install first

```bash
apt-get install socat
sudo pacman -S socat
```

```bash
cd ~
git clone https://github.com/Neilpang/acme.sh.git
cd ./acme.sh
./acme.sh --install
```

## get cert for remote web space

- from here : https://administrator.de/wissen/mikrotik-lets-encrypt-zertifikate-metarouter-instanz-router-erzeugen-355746.html

```bash
#!/bin/sh
# BEGIN VARS
DOMAIN=hotspot.domain.de
WEBROOT=/root/webroot
WEBSPACE=u123456@data.host:/
MIKROTIKSSHHOST=script@10.10.1.1:/
MAXWAITINET=120
# END VARS

# check Internet-Connection
TRIES=0
while ! ping -c 1 google.de >/dev/null 2>&1 ;do
if [ $TRIES -ge $MAXWAITINET ] ;then
  echo "ERROR, NO INTERNET!";
  exit 1
fi
  TRIES=$(($TRIES + 1))
  sleep 1
done

echo "### START generating certificates ###"
# create webroot mount directory
mkdir "$WEBROOT" 2>/dev/null
# unmount if already mountet
umount "$WEBROOT" 2>/dev/null
# mount  webspace root to local directory
sshfs "$WEBSPACE"; "$WEBROOT" -o allow_root
# renew certificate
/root/.acme.sh/acme.sh --issue --webroot "$WEBROOT" -d $DOMAIN --force --log --log-level 2
if [ $? -ne 0 ] ;then
  echo "Error generating certificates with Let's Encrypt, please check '/root/.acme.sh/acme.sh.log'";
  exit 1
fi
# scp certificate and key to Mikrotik
scp /root/.acme.sh/${DOMAIN}/${DOMAIN}.cer /root/.acme.sh/${DOMAIN}/${DOMAIN}.key $MIKROTIKSSHHOST
# unmount webspace
umount "$WEBROOT";
echo "### END generating certificates ###"
```

## letcrypt  debug

```txt
https://letsdebug.net/
```

## acme

```bash
sudo ./acme.sh --issue --webroot /root/webroot/aa/bb/cc/dd/www  -d www.mydomain.de --force --log --debug
```

## sshfs

```bash
# as root
sudo -i
# mount
sshfs <loginname>@<host> <mountpoint>
# umount
fusermount -u <mountpoin>
```

## ssllabs.com

https://www.ssllabs.com/ssltest/viewMyClient.html

<https://gist.github.com/jdeathe/81d4087da8246e9429e533c5d766db16>

## openssl keys

https://dokuwiki.nausch.org/doku.php/centos:mail_c7:mta_5

## import crt

sudo cp /etc/squid/ssl/squid.crt /usr/local/share/ca-certificates/
ls -l /usr/local/share/ca-certificates/
sudo update-ca-certificates --verbose

## install apt-get

sudo apt-get install libltdl-dev
sudo apt-get install libtool-bin  ed

## run boottrap

./boottrap.sh

# create build folder and change

mkdir build && cd $_

## compile squid

./configure \
    --enable-ssl \
    --enable-ssl-crtd \
    --with-openssl \
    --disable-arch-native \
    --prefix=/usr \
    --localstatedir=/var \
    --sysconfdir=/etc/squid \
    --libexecdir=/usr/lib/squid \
    --datadir=/usr/share/squid \
    --with-default-user=proxy \
    --with-logdir=/var/log/squid \
    --with-pidfile=/var/run/squid.pid

./configure \
    --enable-ssl \
    --enable-ssl-crtd \
    --with-openssl \
    --disable-arch-native \
    --prefix=/usr \
    --localstatedir=/var \
    --sysconfdir=/etc/squid \
    --libexecdir=/usr/lib/squid \
    --datadir=/usr/share/squid \
    --with-default-user=proxy \
    --with-logdir=/var/log/squid \
    --with-pidfile=/var/run/squid.pid

## compile

make -j4

## install
make install

## change owner of /var/log/squid to default user

chown -R proxy:proxy /var/log/squid

## create certificate

- from here
https://aws.amazon.com/de/blogs/security/how-to-add-dns-filtering-to-your-nat-instance-with-squid/

```bash
mkdir /etc/squid/ssl
cd /etc/squid/ssl
openssl genrsa -out squid.key 4096
openssl req -new -key squid.key -out squid.csr -subj "/C=XX/ST=XX/L=squid/O=squid/CN=squid"
openssl x509 -req -days 3650 -in squid.csr -signkey squid.key -out squid.crt
cat squid.key squid.crt >> squid.pem
```

## create dhparam keys

```bash
openssl dhparam -outform PEM -out /etc/squid/ssl/dhparam.pem 2048

```

## create cache directory

squid -z

## create cert database

/usr/lib/squid/security_file_certgen -c -s /var/cache/squid/ssl_db -M 4M

## start squid in singel master mode wirth config

squid -NsY -f /etc/squid/squid.conf


## ERROR: Unknown TLS option SINGLE_DH_USE
http://squid-web-proxy-cache.1019090.n4.nabble.com/Transition-from-squid3-5-to-squid4-ciphers-don-t-work-anymore-ERROR-Unknown-TLS-option-SINGLE-DH-USE-td4684794.html
https://wiki.openssl.org/index.php/List_of_SSL_OP_Flags#SSL_OP_SINGLE_DH_USE

## display systzem wide ca-certificates

```bash
awk -v cmd='openssl x509 -noout -subject' '
    /BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt
```
