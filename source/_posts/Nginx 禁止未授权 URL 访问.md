---
title: Nginx 禁止未授权 URL 访问（HTTP 444）
date: 2019-12-21 03:47
tags: [Nginx, 过滤]
category: Services
id: nginx-ban-url
cover: false
---

``` conf
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	listen 443 default_server ssl;
	ssl_certificate /etc/letsencrypt/live/coder17.com-0001/fullchain.pem;
	ssl_certificate_key /etc/letsencrypt/live/coder17.com-0001/privkey.pem;
	server_name _;
	return 444;
}
```

其中证书可以随便指定