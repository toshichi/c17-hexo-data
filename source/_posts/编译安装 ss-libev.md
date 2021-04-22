---
title: 编译安装 ss-libev
date: 2018-08-13 12:38
tags: [ss-libev, 编译, Shadowsocks]
category: Linux
id: compile-ss-libev
cover: false
---

<https://github.com/madeye/shadowsocks-libev>
<http://shadowsocks.org/en/download/servers.html>

Ubuntu 16.04 下无法从源安装，dpkg 编译失败，需要从源码编译

``` bash
sudo apt-get install --no-install-recommends build-essential autoconf libtool libssl-dev gawk debhelper dh-systemd init-system-helpers pkg-config asciidoc xmlto apg libpcre3-dev zlib1g-dev libev-dev libudns-dev libsodium-dev libmbedtls-dev libc-ares-dev automake
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init
./autogen.sh && ./configure && make
sudo make install
```

From <http://shadowsocks.org/en/download/servers.html>

Docker：

``` bash
docker pull shadowsocks/shadowsocks-libev
docker run -e PASSWORD=<password> -p<server-port>:8388 -p<server-port>:8388/udp -d shadowsocks/shadowsocks-libev
```
 
From <http://shadowsocks.org/en/download/servers.html> 