---
title: 配置远程管理 Hyper-V Server
date: 2018-10-09 12:55
tags: [Windows, Hyper-V Server]
category: Windows
id: hyper-v-server-management
cover: .images/配置远程管理%20Hyper-V%20Server/473f9357.png
---

太恶心了，我建议尽量不要使用 Hyper-V Server，珍爱生命，节约时间。

## 1. 安装 Hyper-V Server 系统

<https://www.microsoft.com/en-us/evalcenter/evaluate-hyper-v-server-2016>

## 2. 在客户端（管理端）把目标机（服务器）添加为信任主机

``` powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value 'c17-hyperv-serv'
Get-Item WSMan:\localhost\Client\TrustedHosts
```

可以是计算机名（NetBIOS名），公网域名或者IP，但如果用后两者会导致 Hyper-V Manager 无法管理，非常坑爹。 
而只添加计算机名又会导致后边 Server Manager 中无法管理服务器磁盘，原因不明，非常恶心。 
所以最省事的做法是直接信任全部。 

``` powershell
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
```

去他妈的安全性，不在一个域里也没什么安全可言。 

![配置远程管理 Hyper-V Server_2018-11-22-04-00-13.png](.images/配置远程管理%20Hyper-V%20Server/1eee4b39.png)

## 3. 安装 RSAT

<https://www.microsoft.com/en-us/download/details.aspx?id=45520>

## 4. 启动 Server Manager

添加主机，输入上面信任过的名字，提示 kerberos authentication error。 
如果没信任会提示 WinRX 啥啥的错误。
右键 Manage as，修改用户名密码。 
用户名格式：`c17-hyperv-serv\Administrator`  
密码为管理员密码 
然后就能连上了

![配置远程管理 Hyper-V Server_2018-11-22-04-01-10.png](.images/配置远程管理%20Hyper-V%20Server/48afe458.png)

## 5. 修改本机 hosts 文件

我觉得这步非常不优雅。 
之前为了不改 hosts，绑了个公网域名，但添加到 Hyper-V Manager 的时候总报错，花式报错，提示操作了一个什么不存在的对象，好像是因为它把我的公网域名认作是 Windows 域的名字了。 
添加计算机名绑定到 IP 即可。 
大概其实不添加也行，但毕竟 Netbios 广播不稳定，而且不在同一个子网下也不能用，还是绑了吧。 

![配置远程管理 Hyper-V Server_2018-11-22-04-01-28.png](.images/配置远程管理%20Hyper-V%20Server/587f9a6f.png)

## 6. 设置组策略允许 NTLM 认证

现在添加主机会报这个错

![配置远程管理 Hyper-V Server_2018-11-22-04-03-29.png](.images/配置远程管理%20Hyper-V%20Server/473f9357.png)

总之是很烦人的信任问题。因为主机和客户机不在一个域里面就会老出类似的问题。 
按照里面的提示去组策略搞事情，按照格式在计算机名前面加 WSMAN/

![配置远程管理 Hyper-V Server_2018-11-22-04-03-44.png](.images/配置远程管理%20Hyper-V%20Server/096ccb07.png)

乖乖添加计算机名

![配置远程管理 Hyper-V Server_2018-11-22-04-04-00.png](.images/配置远程管理%20Hyper-V%20Server/eeb9fda2.png)

## 7. 添加凭据

``` powershell
cmdkey /add:c17-hv1 /user:administrator /pass:1qaz@WSX
```

## 8. 滚到 Hyper-V Manager 中添加主机

在 Hyper-V Manager 中添加主机，注意图里的域名要替换成 NetBIOS 名。网上说用 IP 也行但我没成功。

![配置远程管理 Hyper-V Server_2018-11-22-04-04-12.png](.images/配置远程管理%20Hyper-V%20Server/d6178f9b.png)

## 9. 修复远程计算机管理

### 9.1 远程主机

``` powershell
Netsh advfirewall firewall set rule group="Remote Event Log Management" new enable=yes
Netsh advfirewall firewall set rule group="Remote Service Management" new enable=yes
Netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
Netsh advfirewall firewall set rule group="Remote Scheduled Tasks Management" new enable=yes
Netsh advfirewall firewall set rule group="Performance Logs and Alerts" new enable=yes
Netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes
Netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
Netsh advfirewall firewall set rule group="Windows Remote Management" new enable=yes

Set-Service VDS -StartupType Automatic
Cscript \windows\system32\scregedit.wsf /im 1

```

### 9.2 本地主机

``` powershell
Netsh advfirewall firewall set rule group="Remote Volume Management" new enable=yes
```

## 10. 启动远程设备管理器

打开远程组策略

``` powershell
gpedit.msc /gpcomputer: c17-hv1
```

修改

``` path
Computer Configuration\Administrative Templates\System\Device Installation
```

Enable `Allow remote access to the PnP interface`  
如果还不行就用这个[小工具](http://www.device-tool.com)

## 11. 装驱动

正常运行 exe，实在安不上的比如显卡驱动，使用 inf 安装器：

``` cmd
pnputil -i -a *.inf
```

## 12. 其他大概没有用的步骤

这些步骤在其他教程提到，但我没有操作也能使用。

### 12.1 打开 WSManCredSSP服务

连接服务器 PowerShell

![配置远程管理 Hyper-V Server_2018-11-22-04-05-23.png](.images/配置远程管理%20Hyper-V%20Server/6d02347a.png)

``` powershell
Enable-WSManCredSSP -Role server
```

### 12.2 客户端启用身份认证转发

``` powershell
Enable-WSManCredSSP -Role client -DelegateComputer "radar.coder17.com"
```

参考：<https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/manage/remotely-manage-hyper-v-hosts>