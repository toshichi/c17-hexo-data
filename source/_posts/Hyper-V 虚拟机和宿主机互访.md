---
title: Hyper-V 虚拟机桥接公网访问和与宿主机互访
date: 2021-05-05 07:48
tags: [Hyper-V, 虚拟机]
category: Windows
id: hyper-v-network
cover: .images/Hyper-V%20%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%92%8C%E5%AE%BF%E4%B8%BB%E6%9C%BA%E4%BA%92%E8%AE%BF/image-20210505073148867.png
---

使用 Windows 的 Hyper-V 创建虚拟机时，其 Virtual Switch 的设置和其他虚拟机软件相比比较复杂。Virtual Switch 是不具备 DHCP 功能的交换机，因此需要按照交换机思路配置网络。

## 1. 桥接物理网卡访问公网

在虚拟交换机管理器中新建交换机，连接类型选择外部，并选择要桥接的物理网卡。

![image-20210505073148867](.images/Hyper-V%20%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%92%8C%E5%AE%BF%E4%B8%BB%E6%9C%BA%E4%BA%92%E8%AE%BF/image-20210505073148867.png)

给虚拟机添加网卡，并连接到这个交换机。在高级设置中可以修改桥接后网卡的 MAC 地址等。

![image-20210505073413715](.images/Hyper-V%20%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%92%8C%E5%AE%BF%E4%B8%BB%E6%9C%BA%E4%BA%92%E8%AE%BF/image-20210505073413715.png)

进入虚拟机设置 IP 地址即可桥接之，如 Ubuntu 20.02 配置为 DHCP 时：

``` bash
sudo vim /etc/netplan/00-installer-config.yaml
```

``` yaml
network:
  ethernets:
    eth0:
      dhcp4: true
  version: 2
```

## 2. 与宿主机互访

在虚拟交换器管理器添加交换机，类型选择内部，注意不要直接使用自带的 Default Switch，会无法控制固定 IP。

此时在宿主机 Windows 中会出现 `vEthernet` 开头的，与新交换机连接的虚拟网卡。右键属性，TCP/IPv4，在 IP 地址和掩码中指定一个宿主机使用的 IP 地址和网段。

![image-20210505074152587](.images/Hyper-V%20%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%92%8C%E5%AE%BF%E4%B8%BB%E6%9C%BA%E4%BA%92%E8%AE%BF/image-20210505074152587.png)

给虚拟机添加网卡，并连接到这个交换机。在虚拟机中手动设置此网卡 IP 为同一网段，注意网关不要设置，否则会与原有公网网关冲突，跃点数默认为0时会导致断网。

Ubuntu 20.02 的配置：

``` yaml
network:
  ethernets:
    eth0:
      dhcp4: true
    eth1:
      dhcp4: false
      addresses: [192.168.99.2/24]
  version: 2
```

此时路由表中可以看到此网段：

![image-20210505074624014](.images/Hyper-V%20%E8%99%9A%E6%8B%9F%E6%9C%BA%E5%92%8C%E5%AE%BF%E4%B8%BB%E6%9C%BA%E4%BA%92%E8%AE%BF/image-20210505074624014.png)

