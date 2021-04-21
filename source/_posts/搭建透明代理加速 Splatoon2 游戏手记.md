---
title: 搭建透明代理加速 Splatoon2 游戏手记
date: 2018-08-02
tags: [透明代理, Splatoon2, 加速, Shadowsocks]
category: Hacking
id: trans-proxy-splatoon2
cover: .images/搭建透明代理加速%20Splatoon2%20游戏手记/2143eb7f.png
---

上周末，朋友终于带着 Switch 来我家玩耍了。好，棒，很开心。

我发的胖友圈是这样的：

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-20-31.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/1a110660.png)

看起来很开心的样子，然而实际上是这样的：

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-20-41.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/090745e2.png)

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-20-48.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/2143eb7f.png)

以前一直还可以的联通宽带突然爆炸，怎么都连不上老任的服务器。挨着的两个机器甚至无法在好友列表里看到彼此的在线状态。

我天真地以为过几天网就会好起来吧。但周末结束了，我还是连不上 Splatoon。

我不管，我要玩乌贼暖暖。


## 1. 原理与方案选择

加速游戏无非是包转发，之前在 windows 电脑部署的普通 ss 客户端只能转发 http 包。设置其为代理后只能进大厅，无法用 udp 协议与其他玩家通信。

因此需要部署一个能代理 udp 包的东西。

当然，最简单的办法还是买现成的加速器，比如X易的UU，但是很贵，一个月三十。想了想九月份开始任天堂也要收联网服务费了，还是放弃了购买加速器。

自食其力的话，首先想到的是全局微屁恩，但是这东西一来部署起来非常麻烦，二来协议特征太明显，用不了两天就会被安排。

有一个 SS-Tap 号称能把 ss 转成全局的，但我试过之后并不能分享给局域网设备。

那么还是找我们的老朋友小飞机吧，ss-libev 分支有一个 ss-redir 的工具，是专用来做透明代理的，可以一战。

## 2. 软硬环境

硬件上我不想使用路由器刷 op 之类的智能系统的方式，一来刷系统很烦，二来需要多加一个设备。

我当前有一台 7*24 开机的大笔记本（以下称为S），平时做 NAS 服务器使用。那么可以在这个机器上开一个虚拟机装 ubuntu，使用桥接模式接入现有的网络，再作为网关，在 switch 上手动指定即可。

ubuntu 使用了 16.04，32 位，内存随便划了 512M。

## 3. 部署

服务端的部署就不废话了，懒得自己搭买一个也可以的，但注意要加 -u 支持 udp 转发。

客户端在我们刚才的虚拟机里（以下称为A）。装好系统之后，打开 sshd，在本机上使用 ssh 连到虚拟机A。

首先要打开系统的转发模式开关。sudo vim /etc/sysctl.conf ，去掉 net.ipv4.ip_forward=1 的注释。然后 sudo sysctl -p 立即生效。

此时设置局域网内随便一个终端的网关为这个虚拟机的 IP，DNS 可以指定为 114.114.114.114，测试一下应该可以联网。出口 IP 依旧是你本地的出口。我这里使用了另外一台虚拟机（以下称为B）。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-21-15.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/fab63459.png)

参考官方文档，在虚拟机A上编译最新版 ss-libev。

``` bash
sudo apt-get install --no-install-recommends build-essential autoconf libtool libssl-dev gawk debhelper dh-systemd init-system-helpers pkg-config asciidoc xmlto apg libpcre3-dev zlib1g-dev libev-dev libudns-dev libsodium-dev libmbedtls-dev libc-ares-dev automake

git clone https://github.com/shadowsocks/shadowsocks-libev.git

cd shadowsocks-libev

git submodule update --init

./autogen.sh && ./configure && make

sudo make install
```

其实如果用 ubuntu 16.10 以上系统的话是不用自己编译的，软件源里有二进制包可以直接下载。但为了确保版本最新，还是推荐编译。

安装好之后，自己写一个 json 把服务器信息写进去。会用小飞机的都知道我也不废话了。

然后启动 ss-redir，监听的本地端口以 1080 为例。

``` bash
sudo ss-redir -c /etc/s.json -u -v
```

`-u` 是支持 udp 转发的开关，这个前面说过，也需要服务端支持。

`-v` 是废话模式的开关，可以输出很多 info 级的日志便于调试。

打开后应该如图所示，开始监听 1080 端口了。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-22-30.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/680feb28.png)

此时还没有设置转发，在网内其他终端测试出口依旧是本地联通的 IP。

然后编辑 iptables 实现转发。其中 tcp 包通过 redirect 直接重定向到 1080 端口即可。但 udp 包由于是无状态连接，系统无法通过连接跟踪找到它本来的目的地，因此不能直接重定向，需要借助 tproxy 实现。

> 首先我们来了解一下 iptables 的 REDIRECT 重定向的意义，REDIRECT 其实就是 DNAT 目的地址转换，只不过它的目的地址为 127.0.0.1，因此给它取了个形象的名字 - 重定向；DNAT 其实是很粗暴的，就是修改数据包的目的 IP 和目的 Port；那么在 ss-redir 中，它是怎么获取数据包原来的目的 IP 和目的 Port 的呢（就像发快递，你总得知道这个快件要发往哪吧，不然你收到来有什么用）？答案是，借助 Linux 的连接跟踪机制。
>
> 什么是连接跟踪？顾名思义，就是跟踪并记录网络连接的状态。Linux 会为每个经过网络堆栈的数据包都生成一个新的连接记录项，此后，所有属于此连接的数据包都会被唯一分配给这个连接，并标识连接的状态。因此，做了 NAT（网络地址转换）的数据包在内核中都是有记录的。而 ss-redir 只要使用 netfilter 提供的 API 即可从连接记录项中获取数据包原本的目的地址和目的端口，来进行代理。
>
> 但是，上面这种情况只针对 TCP；对于 UDP，如果你做了 DNAT，就无法再获取数据包的原目的地址和目的端口了，具体的技术细节我不清楚，我们只需要知道 UDP 透明代理没有这么简单。
>
> 那么该怎么透明代理 UDP 呢？利用 TPROXY 技术。TPROXY 是在 Kernel 2.6.28 引进的全新透明代理技术，TPROXY 完全不同于传统的 DNAT 方式。TPROXY 实现的透明代理有以下特点：
>
> - 不对 IP 报文做改动（不做 DNAT）；
>
> - 应用层可用非本机 IP 与其它主机建立 TCP/UDP 连接；
>
> - Kernel 通过 iptables-tproxy 和策略路由将非本机流量送到 socket 层；
>
> - 仍需要通过其它技术拦截做代理的流量到代理服务器（WCCP 或 PBR 策略路由）。

以上摘自： <https://paper.tuisec.win/detail/da1a980ab61ce92>

那么对 iptables 执行以下改动（先使用 sudo -i 进入 root 权限 bash）：

``` bash
# SS-REDIR TCP

iptables -t nat -N SSREDIR_TCP


# Bypass ssserver and LAN

iptables -t nat -A SSREDIR_TCP -d ===server ip=== -j RETURN

iptables -t nat -A SSREDIR_TCP -d 0.0.0.0/8 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 10.0.0.0/8 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 127.0.0.0/8 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 169.254.0.0/16 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 172.16.0.0/12 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 192.168.0.0/16 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 224.0.0.0/4 -j RETURN
iptables -t nat -A SSREDIR_TCP -d 240.0.0.0/4 -j RETURN

# Redirect TCP

iptables -t nat -A SSREDIR_TCP -p tcp -j REDIRECT --to-ports 1080

iptables -t nat -A PREROUTING -p tcp -j SSREDIR_TCP

# SS_REDIR UDP

ip rule add fwmark 0x02/0x02 table 100
ip route add local 0.0.0.0/0 dev lo table 100
iptables -t mangle -N SSREDIR_UDP

iptables -t mangle -A SSREDIR_UDP -d ===server ip=== -j RETURN

iptables -t mangle -A SSREDIR_UDP -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A SSREDIR_UDP -d 240.0.0.0/4 -j RETURN

# Redirect UDP

iptables -t mangle -A SSREDIR_UDP -p udp -j TPROXY --on-port 1080 --tproxy-mark 0x02/0x02

# Enable

iptables -t mangle -A PREROUTING -j SSREDIR_UDP

```

其中的 `===server ip===` 是你服务器的 IP。

简单说就是先新建了一个链，把目的地是你服务器地址和其他一些内网地址的包放过去，剩下的全部 tcp 包都转到本地 1080 端口上。然后把这个链加到 PREROUTING 链上，转掉所有入站的 tcp 包。

然后又新建了一个表，规定表里所有的数据包打上一个标记（0x02/0x02，我随便写的值，也可以使用其他值），再新建一个链，同样放过一些特殊地址的包之后，把剩下的 udp 包全部搞进这个表带上标记。再把所有带标记的包转到本地 1080 端口。最后把这个链也挂到PREROUTING 链上，使之生效。

上面两段话用词不太准确，只是说个意思方便理解。

那么加完转发之后，我们的透明代理理论上已经开始工作了。

在虚拟机B里测测看，出口已经变成服务器地址了。在浏览器里开几个页面也都正常显示。此时可以更改 DNS 为 8.8.8.8 了。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-26-09.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/0688bae0.png)

好，爽。

## 4. 坑：桥接无线网卡

高兴的太早了。我上面是在虚拟机里测的。等我把手机和另外一台物理电脑也设置成透明代理做网关之后，却时断时续地打不开网页。甚至我取消 iptables 里面的转发设置时，也不能显示我本地的 IP 出口。

提示的错误也很奇怪，一会儿是 DNS 无法解析，一会儿是无法连接。做网关的虚拟机A里面的日志也是时断时续。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-40-20.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/42067b08.png)

查了半天，毫无头绪，把前面的步骤试了又试也没有变化。

哎，脑壳疼。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-40-32.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/92d8c4eb.png)

但注意到一个问题，那就是我测试的时候，在同一台大电脑上开的另一个虚拟机下测就没问题，用局域网内其他的设备测就时断时续。

在这卡了三天之后，怀疑的目光落在了网卡上。宿主机S因为自带的网卡过于老迈，不支持 5G WiFi，为了保证连接速度我使用了一块水星的 USB 外置网卡。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-40-41.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/389f4ec1.png)

谷歌了一顿之后发现有不少人声称他们的无线网卡无法在 VirtualBox 等虚拟机软件里设置为桥接模式。原因是无线网卡通常不支持混杂模式，无法接收非主机 IP 地址的包。

但我这个能桥接啊，真的是它的问题么？

我尝试把虚拟机 A 和 B 桥接的网卡都改回了笔记本自带的 Intel 网卡。这次是真的不能桥接了，完全无法联网，在路由器后台也看不见两个虚拟机。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-40-54.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/3594aac8.png)

那看来网卡的嫌疑真的很大，那我们试试有线连接吧。

我之前的电力猫送人了，但路由器在客厅，想要物理接入的话只能把宿主机笔记本S抱过去。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-41-04.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/9193b80c.png)

然后桥接有线网卡，再试，破案了，网内所有终端都能正常联网了。

这个坑最坑的地方在于，无线网卡对混杂模式支持的不完整，虽然能正常桥接联网，但却无法转发所有的入站包，使问题难以定位。

## 5. 坑：MTU

终于填好了坑，我们可以愉快地填下一个坑了。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-41-28.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/d19c73a7.png)

把 switch 也接入到网关下之后，发现能正常登录、进房间，但无法和其他用户连接。

显然是 udp 的哪里出了问题吧。但看日志也挺正常的啊，所有的请求都有回应。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-41-40.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/28a82285.png)

这时我注意到，在使用 curl 请求某个地址的时候，总是先发出两个 udp 包，等待五秒后，又发出两个 udp 包，才解析成功。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-41-51.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/b24336d1.png)

但直接 nslookup 的时候又能立即返回结果。

这个现象十分诡异，我到现在也不能解释。

客户端没有发现问题，那么看看服务端吧。由于之前测试一直用的是购买的服务，看不到日志。所以我又临时开了一台 vps，搭了个服务端来看日志。

诡异的是使用自己搭的服务端就没有这个问题了，秒查秒回。

只能理解成大概购买的服务开了某种多重发包的插件吧。

但问题依然没有解决。

尝试开了一局游戏，发现在匹配对手的过程中，客户端快速滚过的日志可以看出游戏在反复试图与其他玩家的 ip 发 udp 包试图连接。但服务端的日志滚动速度明显低于客户端。

怀疑丢包了。

丢包最大的可能性是 udp 包在传输路径上被 ISP 给丢弃了。udp 包优先级不高，如果 QoS 策略比较激进那么丢包的概率很高。

但我用 nc 测了测 udp，发现并没有丢包。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-42-03.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/47be85fe.png)

陷入沉思，在网上随便搜索的时候，看到这么一个帖子：

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-42-14.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/6a9275db.png)

啥玩意儿？MTU 超了居然不拆分而是直接丢包？难怪我用 nc 发小包测的时候不丢。

联想到之前在 github 上看 madeye 大神回的 issue 里也提到过建议一个 xbox 连不上的哥们试试改 MTU 小一点，我就死马当活马医地在 switch 里把 MTU 从 1400 改成了 1390.。

然后我特么就进！游！戏！了！

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-42-24.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/dd221766.png)

看着屏幕上翻滚的日志我是真的想拥抱大海。

![搭建透明代理加速 Splatoon2 游戏手记_2018-11-26-13-42-36.png](.images/搭建透明代理加速%20Splatoon2%20游戏手记/427aefa6.png)

（然后我输了，对面的马桶是真的不知到该怎么打掉


## 6. 总结优化

这次一共遇到两个迷惑性较大的坑，一个是无线网卡的混杂模式，因为一直以来工作得很好，我并没有第一时间怀疑它。

另一个是 MTU 的问题，正常讲数据包大于 MTU 时会被拆分，但 ss-libev 作了丢包的操作不知道是出于什么考虑，可能是消除协议特征？

最后那个 curl 会 DNS 查两次的问题依然没有头绪。不过后来将服务端拆掉换回买的服务之后依然可以正常连接，说明这个问题并没有实际影响，暂且不管吧。

至于方案的优化，后期把写 iptables 和开 ss-redir 服务的命令写到 rc.local 里开机启动即可。注意 rc.local 加载时系统的环境变量不完整，启动 ss-redir 需要指定其完整路径，可以使用 which ss-dir 或者 whereis ss-dir 命令查看。

作为网关的虚拟机A也可以调小内存，大概 256M 也可以正常工作的。

宿主机S决定就让它呆在路由器旁边了，一个服务器是不需要放在卧室里的。回头把外接的硬盘盒和 UPS 也搬过去。

坑就这么多，谢谢观赏。

参考资料：

<http://ezlost.tk/2018/02/24/ss-redir/>

<https://blog.csdn.net/lvshaorong/article/details/52909055>

<https://blog.csdn.net/lvshaorong/article/details/53203674>

<https://github.com/shadowsocks/shadowsocks-libev/issues/1883>

<https://cn.aliyun.com/jiaocheng/148168.html>

<https://github.com/shadowsocks/shadowsocks-libev/issues/1566>

<https://lixingcong.github.io/2018/06/11/ss-redir-ipset/>

<https://usodesu.ga/2018-04-26/OpenWrt-Transparent-Proxy-with-ss-redir/>

<https://doub.io/ss-jc34/>