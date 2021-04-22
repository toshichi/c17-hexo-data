---
title: Nextcloud https 协议有混合内容无法显示
date: 2018-08-13 12:37
updated: 2020-08-03 02:58
tags: [Nextcloud, https]
category: Services
id: nextcloud-https-mixed-content
cover: .images/Nextcloud%20https%20协议有混合内容无法显示/53dc8f1d.png
---

提示 csp 屏蔽，一般由反向代理导致。

###  Docker部署时：

设置环境变量：

``` yml
APACHE_DISABLE_REWRITE_IP: 1
TRUSTED_PROXIES: 172.16.0.0/12 # 反向代理地址，一般为 docker 虚拟网关地址
```

或者设置：

``` yml
OVERWRITEPROTOCOL: https
```

From: <https://github.com/nextcloud/docker>



### 独立部署时：

修改 config/config.php：

``` php
'overwrite.cli.url' => 'https://cloud.myserver.com', 
'overwriteprotocol' => 'https',
```

From: <https://help.nextcloud.com/t/nextcloud-wont-load-any-mixed-content/13565> 

![Https 协议有混合内容无法显示_2018-11-26-03-09-48.png](.images/Nextcloud%20https%20协议有混合内容无法显示/53dc8f1d.png)