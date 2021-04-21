---
title: ss-tunnel 转发 dns
date: 2019-05-19 20:35
tags: [Linux, ss-tunnel, Shadowsocks]
category: Linux
id: ss-tunnel-dns
cover: false
---

``` bash
nohup sudo /usr/local/bin/ss-tunnel -c /etc/shadowsocks-libev/config.json -l 53 -v -b 127.0.0.1 -L 8.8.8.8:53 -u > /dev/null 2>&1 &
```