---
title: Windows Sandbox 桥接网络
date: 2020-10-05 01:34
tags: [Windows Sandbox, 桥接]
category: Windows
id: windows-sandbox-bridged
cover: .images/Windows%20Sandbox%20桥接网络/image-20201005020903542.png
---

使用 Windows 10 的 Sandbox 有时需要桥接主机网络，默认启动时是 NAT 网络，无法访问主机所在网络资源。

1. 启动 Sandbox，主机的网络管理中会出现 `vEthernet (Default Switch)`

2. 按住 Ctrl 同时选择上述连接与当前联网的连接，右键选择桥接。

    ![image-20201005020749879](.images/Windows%20Sandbox%20桥接网络/image-20201005020749879.png)

3. 如果报错提示预想外的错误，直接确定，可以看到两个连接中有一个已经加入桥接，另一个没有。如果是图中这样只有 vEthernet 在桥接中，则删除桥接，重复上一步重新添加，否则会导致主机断网。直到不报错，或者只有当前外部连接加入桥接时为止。

    ![image-20201005020903542](.images/Windows%20Sandbox%20桥接网络/image-20201005020903542.png)

4. 在没有加入桥接的 vEthernet 连接上右键，选择加入桥接，即可看到两个连接均为桥接。

    ![image-20201005021549546](.images/Windows%20Sandbox%20桥接网络/image-20201005021549546.png)

5. 此时在沙箱中查看 IP 应该已经处于同一网段。如果不成功则关闭沙箱重开，从上一步继续。