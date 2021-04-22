---
title: 搭建 Shadowsocks 客户端服务端并加为服务
date: 2018-08-16 18:35
tags: [Shadowsocks, 服务端]
category: Services
id: shadowsocks-server
cover: false
---

<https://gist.github.com/SykieChen/0996b1d1644e2a9d2f7b5b78a71caf2e>

## 1. install and config

``` bash
sudo apt install python-pip
sudo apt install shadowsocks
or
sudo pip install git+https://github.com/shadowsocks/shadowsocks.git@master
```

## 2. 配置

### 2.1 客户端

``` bash
sudo vi /etc/shadowsocks.json
```

``` json
{
	"server": "27.102.111.111",
	"local_address": "127.0.0.1",
	"local_port": 1080,
	"server_port": 12345,
	"password": "passsss",
	"timeout": 300,
	"method": "aes-256-cfb"
}
```

### 2.2 服务端

``` bash
sudo vi /etc/ssserver.json
```

``` json
{
	"server": "0.0.0.0",
	"local_address": "127.0.0.1",
	"local_port": 1080,
	"timeout": 300,
	"method": "aes-256-cfb",
	"port_password": {
		"3389": "passsss",
		"2003": "passsss"
	}
}
```

或者

``` json
{
	"server":"0.0.0.0",
	"server_port":3389,
	"local_address": "127.0.0.1",
	"local_port":1080,
	"password":"passsss",
	"timeout":300,
	"method":"aes-256-cfb",
	"fast_open": false
}
```

## 3. add as service

### 3.1 客户端

``` bash
sudo vim /etc/systemd/system/shadowsocks.service
```

``` ini
[Unit]
Description=Shadowsocks Client Service
After=network.target

[Service]
Type=simple
User=tojo
ExecStart=/usr/bin/sslocal -c /etc/shadowsocks.json

[Install]
WantedBy=multi-user.target
```

``` bash
sudo systemctl enable /etc/systemd/system/shadowsocks.service
sudo systemctl start shadowsocks.service
service shadowsocks status
```

### 3.2 服务端

``` bash
sudo vim /etc/systemd/system/ssserver.service
```

``` ini
[Unit]
Description=Shadowsocks Server Service
After=network.target

[Service]
Type=simple
User=tojo
ExecStart=/usr/local/bin/ssserver -c /etc/ssserver.json

[Install]
WantedBy=multi-user.target
```

``` bash
sudo systemctl enable /etc/systemd/system/ssserver.service
sudo systemctl start ssserver.service
```