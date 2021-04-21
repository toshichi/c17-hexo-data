---
title: 华硕路由添加 DDNS 服务
date: 2020-03-05 02:05
tags: [华硕, 路由器, Merlin, DDNS]
category: Hacking
id: asus-ddns
cover: false
---

以 dockdns 为例，必须安装 Merlin 固件。

```shell
vi /jffs/scripts/ddns-start
```

``` bash
# register a subdomain at https://www.duckdns.org/ to get your token
SUBDOMAIN="your_subdomain"
TOKEN="your-token"

# no modification below needed
curl --silent "https://www.duckdns.org/update?domains=$SUBDOMAIN&token=$TOKEN&ip=$1" >/dev/null 2>&1
if [ $? -eq 0 ];
then
    /sbin/ddns_custom_updated 1
else
    /sbin/ddns_custom_updated 0
```

```shell
chmod a+rx /jffs/scripts/*
```

并在 web 设置中 `Administration -> System` 启用用户脚本，在 `WAN -> DDNS -> DDNS Service` 中设置为`custom` 即可。