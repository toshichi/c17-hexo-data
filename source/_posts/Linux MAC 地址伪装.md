---
title: Linux MAC 地址伪装
date: 2020-04-06 18:01
tags: [Linux, MAC 地址伪装]
category: Linux
id: linux-mac-faking
cover: false
---

[https://wiki.archlinux.jp/index.php/MAC_アドレス偽装#.E6.96.B9.E6.B3.95_1:_systemd-networkd](https://wiki.archlinux.jp/index.php/MAC_アドレス偽装#.E6.96.B9.E6.B3.95_1:_systemd-networkd)

Tested on Ubuntu 18.04 LTS

创建系统服务，每次开机时使用 ip link set 修改 mac 地址。

``` bash
sudo vim /etc/systemd/system/macspoof@.service
```

``` ini
[Unit]
Description=MAC Address Change %I
Wants=network-pre.target
Before=network-pre.target
BindsTo=sys-subsystem-net-devices-%i.device
After=sys-subsystem-net-devices-%i.device

[Service]
Type=oneshot
ExecStart=/sbin/ip link set dev %i address 90:2b:34:d2:15:25
ExecStart=/sbin/ip link set dev %i up

[Install]
WantedBy=multi-user.target
```

``` bash
sudo systemctl enable macspoof@eth0.service
```

已知问题：有时涉及网络的重启（推测如 docker）会导致失效。此时需要重启服务。

``` bash
sudo service macspoof@eno2 restart
```


