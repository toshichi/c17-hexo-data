---
title: Windows 远程桌面固定 DPI
date: 2018-09-23 16:14
tags: [Windows, RDP, DPI]
category: Windows
id: windows-rdp-fix-dpi
cover: .images/Windows%20远程桌面固定%20DPI/f70e5359.png
---

智障远程桌面会自适应客户机的 DPI，很烦人，每次布局都会变。  
而且家里电脑的 VirtualBox 会出 bug，客户机非 100% 缩放连上去时，窗口标题会消失，在窗口上点右键直接蓝屏，提示 win32kfull.sys 崩溃，查了查大概是虚拟机驱动的问题。Chrome 在此模式下下载文件也会崩溃。  
公司电脑没毛病，大概率是系统问题。但懒得重装，本着最懒原则直接禁用自适应 DPI 比较方便。  
在服务端修改注册表：  

``` reg
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations
```

新建32位DWORD `IgnoreClientDesktopScaleFactor`  
设为1  

``` cmd
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations" /v IgnoreClientDesktopScaleFactor /t REG_DWORD /d 1
```



重启。

![Windows 远程桌面固定 DPI_2018-11-22-03-58-21.png](.images/Windows%20远程桌面固定%20DPI/f70e5359.png)

<https://social.technet.microsoft.com/Forums/en-US/7260267b-686d-4271-9dc2-5ae76e733e3f/disable-dpi-scaling-sync-for-remote-desktop-protocol-81>