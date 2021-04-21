---
title: 配置 Shadowsocks 服务时 iptables 中的一处坑
date: 2016-12-23
tags: [Shadowsocks, iptables, 科学上网, Linux]
category: Services
id: ss-iptables
cover: .images/%E9%85%8D%E7%BD%AE%20Shadowsocks%20%20%E6%9C%8D%E5%8A%A1%E6%97%B6%20iptables%20%E4%B8%AD%E7%9A%84%E4%B8%80%E5%A4%84%E5%9D%91/image-20210421175536250.png
---

前几天把 ss 服务器从 ConoHa 迁移到 Linode 的东京2节点，丢包情况有所改善。

迁移后为了安全我重新配置了防火墙，只允许需要的端口通过。但在配置 ss 梯子服务时遇到了坑。在放行 ss 端口的情况下，ss 的手机客户端发生无法解析地址的情况，关掉防火墙则服务恢复正常，电脑端也一切正常。

iptables 配置如下：

``` iptables
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A OUTPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT

# DNS
-A OUTPUT -p udp --dport 53 -j ACCEPT
-A INPUT -p udp --sport 53 -j ACCEPT

# SSH is 23333
-A INPUT -p tcp -m multiport --dports 22,23333 -j ACCEPT
-A OUTPUT -p tcp -m multiport --sports 22,23333 -j ACCEPT

# http client
-A INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT
-A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

# http server
-A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
-A OUTPUT -p tcp -m multiport --sports 80,443 -j ACCEPT

# shadowxxx
-A INPUT -p tcp -m multiport --dports 6666,7777 -j ACCEPT
-A INPUT -p udp -m multiport --dports 6666,7777 -j ACCEPT
-A OUTPUT -p tcp -m multiport --sports 6666,7777 -j ACCEPT
-A OUTPUT -p udp -m multiport --sports 6666,7777 -j ACCEPT

# kcptun
-A INPUT -p udp --dport 6677 -j ACCEPT
-A OUTPUT -p udp --sport 6677 -j ACCEPT
-A INPUT -p tcp --dport 6677 -j ACCEPT
-A OUTPUT -p tcp --sport 6677 -j ACCEPT

# drop
-P INPUT DROP
-P OUTPUT DROP
-P FORWARD ACCEPT

COMMIT
```

我百思不得其解，分析了各种可能性，最后只能开启日志找问题。

修改 /etc/rsyslog.conf ，添加一行：

`kern.*   /var/log/iptables.log`

将内核日志重定向到 iptables.log 方便查看。

在 iptables 文件中最后的 drop 前添加了 -A OUTPUT -j LOG，把所有被 drop 的数据包记录下来。

然后用 `tailf /var/log/iptables.log` 滚动输出日志。

日志输出如图：

![image-20210421175608972](.images/%E9%85%8D%E7%BD%AE%20Shadowsocks%20%20%E6%9C%8D%E5%8A%A1%E6%97%B6%20iptables%20%E4%B8%AD%E7%9A%84%E4%B8%80%E5%A4%84%E5%9D%91/image-20210421175608972.png)

可以看到有大量的53端口 DNS 查询被丢弃，但我已经在 iptables 中放行了 dns 查询啊？为什么呢？？？

![image-20210421175636741](.images/%E9%85%8D%E7%BD%AE%20Shadowsocks%20%20%E6%9C%8D%E5%8A%A1%E6%97%B6%20iptables%20%E4%B8%AD%E7%9A%84%E4%B8%80%E5%A4%84%E5%9D%91/image-20210421175636741.png)



瞪了屏幕两分钟后发现这些查询都是 tcp 协议的，而我只放行了 udp 的 DNS包。

普通的 DNS 都是 udp 传输的，而手机端的 ss 似乎默认使用了 tcp 方式的 DNS 查询，导致数据包被丢弃。

在 iptables 中允许53端口 tcp 包后问题解决。