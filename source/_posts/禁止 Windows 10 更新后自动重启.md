---
title: 禁止 Windows 10 更新后自动重启
date: 2018-09-14 11:37
tags: [Windows, 自动更新, 重启]
category: Windows
id: windows-update-restart
cover: .images/%E7%A6%81%E6%AD%A2%20Windows%2010%20%E6%9B%B4%E6%96%B0%E5%90%8E%E8%87%AA%E5%8A%A8%E9%87%8D%E5%90%AF/image-20210421183749607.png
---

昨晚上微软又分发更新并且强制重启了，我四台电脑只幸存了一台，其他上面开的虚拟机和工作环境啥的都没了。

很生气，研究了一下为啥幸存了一台，发现一年前我就给它动过手脚，当时我打着游戏呢就重启了。查阅了一下自己当时的记录，复现了一下，分享给大家。

设置组策略什么的都不好用，早晚还是要被微软强奸。
排查后发现重启是由任务计划中：

`\Microsoft\Windows\UpdateOrchestrator`

这个任务触发的，查看其上次启动时间就可以看到 Windows 的重启时间：

![禁止 Windows 10 更新后自动重启_2018-11-22-03-10-44.png](.images/禁止%20Windows%2010%20更新后自动重启/5e4ff6f6.png)

但这个任务是系统用户创建的，我们自己没有权限搞死它。
研究一下任务干了什么：

![禁止 Windows 10 更新后自动重启_2018-11-22-03-11-33.png](.images/禁止%20Windows%2010%20更新后自动重启/71dd76f9.png)

看到是执行了：

``` path
%systemroot%\system32\MusNotification.exe
```

这个程序来重启。进到系统目录下看看这个文件：

![禁止 Windows 10 更新后自动重启_2018-11-22-03-11-46.png](.images/禁止%20Windows%2010%20更新后自动重启/e985485d.png)

发现其实是一个硬链接。而且这个程序即使删除或修改，在下次更新后也会自动恢复。我们只想禁止自动更新后的重启，并不是不更新。

![禁止 Windows 10 更新后自动重启_2018-11-22-03-44-14.png](.images/禁止%20Windows%2010%20更新后自动重启/e4e15ead.png)

所以只能用 IFEO 映像劫持了：

![禁止 Windows 10 更新后自动重启_2018-11-22-03-44-46.png](.images/禁止%20Windows%2010%20更新后自动重启/6adb1ad4.png)

路径：

``` reg
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options
```

新建一个 Key，改名 `MusNotification.exe`：

![禁止 Windows 10 更新后自动重启_2018-11-22-03-45-24.png](.images/禁止%20Windows%2010%20更新后自动重启/8d4ed555.png)

在右边新建字符串值，命名 `debugger`，值 `cscript.exe`（图中错误）。这个程序不带参数是啥也不会做的。

![禁止 Windows 10 更新后自动重启_2018-11-22-03-45-53.png](.images/禁止%20Windows%2010%20更新后自动重启/37d84338.png)

重启一下，然后就再也不会重启了。