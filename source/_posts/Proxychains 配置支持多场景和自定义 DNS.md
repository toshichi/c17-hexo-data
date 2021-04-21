---
title: Proxychains 配置支持多场景和自定义 DNS
date: 2019-05-19 18:20
tags: [Linux, Proxychains, DNS]
category: Linux
id: proxychains-dns
cover: false
---

Proxychains 开启时使用的是写死的公用 DNS 4.2.2.2，并不科学。同时只能支持一个代理或代理链，需要切换使用多个代理时并不方便。

下面以使用 `pc` 和 `pf` 两个命令分别连接两个不同的代理为例:

## 链接 ss 的代理

``` bash
sudo vim /etc/proxychains.conf
```

``` ini
strict_chain
quiet_mode
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5  127.0.0.1 1080
```

## 链接 fiddler 的代理

``` bash
sudo vim /etc/proxyfiddler.conf
```

``` ini
strict_chain
quiet_mode
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
http  127.0.0.1 8888
```

## usage

- `pc xx` : use socks5 proxy 127.0.0.1:4411 to connect to xx
- `pf xx` : use http proxy 127.0.0.1:8888 to connect to xx, usually fiddler


## Proxychains 4 NG

新版没有以前不能解析域名的问题，直接安装即可。
但 Proxychains4 不支持 git，原因不明，会报错，因此使用 ProxychainsNG

```bash
git clone https://github.com/rofl0r/proxychains-ng.git
cd proxychains-ng
./configure && make && sudo make install
cd .. && rm -rf proxychains-ng

echo alias pc=\'proxychains4\' >> ~/.bash_aliases
sudo ln -s ~/.bash_aliases /root/.bash_aliases

echo alias pf=\'proxychains4 -f /etc/proxyfiddler.conf\' >> ~/.bash_aliases
```

--------

## 以下适用于 Proxychains 3 版本，已过时

### 改源码支持指定 dns

``` bash
mkdir $HOME/.proxychains
sudo vim /usr/lib/proxychains3/proxyresolv
```

``` bash
#!/bin/sh
# This script is called by proxychains to resolve DNS names

# DNS server used to resolve names
DNS_SERVER=${PROXYRESOLV_DNS:-4.2.2.2}


if [ $# = 0 ] ; then
    echo " usage:"
    echo "  proxyresolv <hostname> "
    exit
fi


export LD_PRELOAD=libproxychains.so.3

if [ $DNS_SERVER = "none" ] ; then
    dig $1 +tcp | awk '/A.+[0-9]+\.[0-9]+\.[0-9]/{print $5;}'
else
    dig $1 @$DNS_SERVER +tcp | awk '/A.+[0-9]+\.[0-9]+\.[0-9]/{print $5;}'
fi
```

``` bash
echo alias pf='ln -sf /etc/proxyfiddler.conf $HOME/.proxychains/proxychains.conf; PROXYRESOLV_DNS=none proxychains' >> ~/.bash_aliases
echo alias pc='ln -sf /etc/proxychains.conf $HOME/.proxychains/proxychains.conf; proxychains' >> ~/.bash_aliases

sudo ln -s ~/.bash_aliases /root/.bash_aliases
sudo ln -s ~/.proxychains /root/.proxychains
```