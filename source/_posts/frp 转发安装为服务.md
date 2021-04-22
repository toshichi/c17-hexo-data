---
title: frp 转发安装为服务
date: 2018-09-20 03:48
tags: [frp, 安装服务]
category: Services
id: frp-install-service
cover: false
---

下载 frp 到 `/opt/frp`

``` bash
sudo chown -R tojo /opt/frp
sudo chmod -R 755 /opt/frp
```

## 1 配置

### 1.1 客户端

``` bash
vim /opt/frp/frpc.ini
```

``` ini
[common]
server_addr = frp.coder17.com
server_port = 3389

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 60022

[ss-tcp]
type = tcp
local_ip = 127.0.0.1
local_port = 8848
remote_port = 60088

[ss-udp]
type = udp
local_ip = 127.0.0.1
local_port = 8848
remote_port = 60088
```

### 1.2 服务端

``` bash
vim /opt/frp/frps.ini
```

``` ini#
[common]
bind_port = 3389
vhost_http_port = 60080
vhost_https_port = 60443
subdomain_host = frp.coder17.com
dashboard_port = 60000
dashboard_user = tojo
dashboard_pwd = 1qaz@WSX3edc
```

## 2 安装为服务

### 2.1 客户端

``` bash
sudo vim /etc/systemd/system/frpc.service
```

``` ini
[Unit]
Description=frp Client Service
After=network.target

[Service]
Type=simple
User=tojo
ExecStart=/opt/frp/frpc -c /opt/frp/frpc.ini

[Install]
WantedBy=multi-user.target

```

``` bash
sudo systemctl enable /etc/systemd/system/frpc.service
sudo systemctl start frpc.service
service frpc status
```

### 2.2 服务端

``` bash
sudo vim /etc/systemd/system/frps.service
```

``` ini
[Unit]
Description=frp Server Service
After=network.target

[Service]
Type=simple
User=tojo
ExecStart=/opt/frp/frps -c /opt/frp/frps.ini

[Install]
WantedBy=multi-user.target

```

``` bash
sudo systemctl enable /etc/systemd/system/frps.service
sudo systemctl start frps.service
service frps status
```