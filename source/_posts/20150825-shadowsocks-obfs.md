---
title: Shadowsocks + obfsproxy 混淆翻墙的实现
date: 2015-08-25 02:58:03
tags: [Linux, VPS, 科学上网]
category: [小技术, Linux]
id: 20150825-shadowsocks-obfs
---
&emsp;&emsp;Shadowsocks 的作者 [@clowwindy](https://twitter.com/clowwindy) 近期被喝茶了，并被迫删除了 Github 上的源码。这意味着 ss 以后不会得到更新，其流量特征也许会被不断进化的 GFW 识别并封锁。故使用 obfsproxy 进行二次混淆，降低被识别的风险。
&emsp;&emsp;以下步骤均在 Debian 7 32 位系统上进行。


## 1. 配置 shadowsocks-libev 服务端 ##
参考[官方文档](https://github.com/shadowsocks/shadowsocks-libev)，这里从源直接安装。

添加 GPG public key
```bash
wget -O- http://shadowsocks.org/debian/1D27208A.gpg | sudo apt-key add -
```
<!-- more -->
向 `/etc/apt/sources.list` 添加以下内容
```
deb http://shadowsocks.org/debian wheezy main
```
执行以下命令安装
```bash
sudo apt-get update
sudo apt-get install shadowsocks-libev
```
安装完成后编辑`/etc/shadowsocks-libev/config.json` 文件配置加密方式与端口

```json
{
    "server":"0.0.0.0",
    "server_port":2333,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"---",
    "timeout":600,
    "method":"aes-256-cfb"
}
```
server 填写 0.0.0.0 允许所有设备连接，填写 127.0.0.1 则仅允许本机内环连接。
加密方式一般选择 aes-256-cfb。
配置完成后执行
```bash
sudo /etc/init.d/shadowsocks-libev start
```
启动ss服务端。



## 2. 配置 shadowsocks 客户端（Windows 平台） ##
在 http://shadowsocks.org/en/download/clients.html 下载 win 客户端
启动后在 GUI 中填写服务器信息并保存，本地端口以666举例。
右击托盘图标以配置开机启动，将代理方式设置为 PAC。视情况使用 PAC 脚本或搭配 SwitchyOmega + Chrome 使用。
若连接正常，则继续进行 obfsproxy 的部署。



##3. 配置 obfsproxy 服务端 ##

使用 python-pip 安装：
```bash
apt-get install gcc python-pip python-dev
pip install obfsproxy
```
运行服务端：
```bash
/usr/local/bin/obfsproxy --data-dir=/tmp/scramblesuit-server scramblesuit --password=FANGBINXINGFUCKYOURMOTHERSASS444 --dest=127.0.0.1:2333 server 0.0.0.0:23333
```
scramblesuit 是一种安全性稍高的加密工作方式，该方式工作时需要临时文件夹存放yaml ticket，故用 --data-dir 参数指定目录。--password 指定了加密密码，必须为 BASE32 字符，即大写字母加数字共32位的字符串。
--dest 指定目标端口，此处填写 ss 服务端口。 server 为混淆后对外监听端口，0.0.0.0 表示允许所有网段地址连接。
运行成功后会提示
```
2015-08-25 21:22:02,412 [WARNING] Obfsproxy (version: 0.2.13) starting up.
2015-08-25 21:22:02,412 [ERROR]
################################################
Do NOT rely on ScrambleSuit for strong security!
################################################
```

并不知道那句 [ERROR] 是什么意思，所以不要理它好了=。=
启动成功后需要将其加入自启动。编辑`/etc/rc.local` 文件添加如下内容
```bash
(/usr/local/bin/obfsproxy --data-dir=/tmp/scramblesuit-server scramblesuit --password=FANGBINXINGFUCKYOURMOTHERSASS444 --dest=127.0.0.1:2333 server 0.0.0.0:23333 >/dev/null 2>&1 &)
```
包括最外层括号。
重启 VPS，服务端应已开始工作。

##4. 配置 obfsproxy 客户端 ##

Tor 并没有提供单独的 obfsproxy 客户端下载，需要手动从 Tor Browser 安装包中提取。
在 https://www.torproject.org/projects/obfsproxy.html.en 下载 Tor Browser with obfsproxy
下载后作为压缩包打开，定位至 `Browser\TorBrowser\Tor\PluggableTransports\`
由于客户端程序有依赖，故将该目录下除子目录 fteproxy 外的所有文件提取至单独文件夹中。
运行客户端：
```bat
obfsproxy\obfsproxy.exe scramblesuit --password=FANGBINXINGFUCKYOURMOTHERSASS444 --dest=www.devchen.com:23333 client 127.0.0.1:6666
```
运行成功的提示与服务端的类似。
客户端将运行在本机 6666 端口上，修改 shadowsocks 客户端参数，服务器地址填入 127.0.0.1，端口 6666。测试连接是否成功。
将客户端加入 Windows 自启动。由于启动后会产生一个控制台窗口，故需要用 vbs 启动客户端以隐藏控制台窗口。
```VBScript
CreateObject("WScript.Shell").Run "obfsproxy\obfsproxy.exe scramblesuit --password=FANGBINXINGFUCKYOURMOTHERSASS444 --dest=www.devchen.com:6667 client 127.0.0.1:4243",0
```
存为 VBS 文件，到`C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp`(Windows 8.1)


##5. 总结 ##

全部完工后端口如下：
服务端：
2333   -   Shadowsocks 服务端口
23333  -   obfsproxy 转发服务端口

客户端：
666    -   Shadowsocks 代理服务端口
6666   -   obfsproxy 转发服务端口

加入 obfs 混淆后访问速度及稳定性明显增加。


<p align = right>
by Sykie Chen
2015.8.25
</p>