---
title: Windows 10 商店应用无法启动解决
date: 2018-12-11
tags: [Windows, Windows 10, UWP, Store]
category: Windows
id: uwp-crash
cover: .images/Windows%2010%20商店应用无法启动解决/a15862ae.png
---

Bug 10 的桌面版商店应用全崩了，提示没有权限啥啥啥，脑壳疼。 
今天发现截图软件崩了，试图重启的时候弹出一个框告诉我访问啥啥没权限。  

![Windows 10 商店应用无法启动解决_2018-12-11-18-40-49.png](.images/Windows%2010%20商店应用无法启动解决/a15862ae.png)

哦擦这是什么鬼呢。

顺着提示找到路径 `C:\Users\<username>\AppData\Local\Microsoft\WindowsApps`，发现是放置所有从 Windows Store 安装的桌面应用的地方。注意是桌面应用而不是 UWP 应用。 
进到目录里看到所有的 exe 都是 0KB 没有图标的，双击后弹出一样的错误框。查看整个 WindowsApps 目录发现是没有大小的。 

![Windows 10 商店应用无法启动解决_2018-12-11-18-43-09.png](.images/Windows%2010%20商店应用无法启动解决/a0ce7d67.png)

起初以为是目录文件损坏，找出了一周前的系统备份镜像发现备份中的这个目录也是一样的 0KB。这就比较棘手了。 

尝试启动了一下 WSL 的那个 Ubuntu 图标，发现也报一样的错误。搜索后发现 Github 上[有一个 issue](https://github.com/Microsoft/WSL/issues/2323) 在研究这个问题。 
看了看其中的解决方式，重置 Windows Store 什么的都不好使。 
尝试右键管理员运行，依然报错。但注意到选择管理员运行后先弹出了 UAC 提权框，其中的程序图标是正常显示的。于是怀疑并不是这个 exe 本身有权限问题，而是 exe 运行后访问的某个资源有权限问题。 
在 Github 的那个 issue 中看到[有人建议](https://github.com/Microsoft/WSL/issues/2323#issuecomment-412823470)使用 [Process Monitor](https://docs.microsoft.com/en-us/sysinternals/downloads/procmon) 检测一下到底是什么权限问题。 

![Windows 10 商店应用无法启动解决_2018-12-11-18-53-13.png](.images/Windows%2010%20商店应用无法启动解决/754e95d7.png)

于是使用 Procmon 抓取启动后的 `ACCESS DENIED` 记录：

![Windows 10 商店应用无法启动解决_2018-12-11-18-53-29.png](.images/Windows%2010%20商店应用无法启动解决/f958d8d3.png)

看到三条注册表访问和一条文件访问，从路径看那条文件访问的嫌疑很大。于是查看该路径 `C:\Users\<username>\AppData\Local\Packages` 的权限：

![Windows 10 商店应用无法启动解决_2018-12-11-18-54-45.png](.images/Windows%2010%20商店应用无法启动解决/db6e5d86.png)

发现只有自己，感觉不太对，又在任务管理器中查看了 PID 10148 的那个 svchost 进程，发现用户名是 SYSTEM。

![Windows 10 商店应用无法启动解决_2018-12-11-18-55-52.png](.images/Windows%2010%20商店应用无法启动解决/4190a952.png)

那么问题应该很明显了，这个宿主进程没有权限访问存储了 Windows 商店应用数据的目录。

为了确认问题，找了另一个机器查看对应目录的权限，发现应该除了当前用户之外，还有 SYSTEM 用户和 Administrators 用户组的完全访问权限。

![Windows 10 商店应用无法启动解决_2018-12-11-18-57-14.png](.images/Windows%2010%20商店应用无法启动解决/be890d1d.png)

于是给对应目录添加了这两组权限，再试，还报错。重新抓取动作后发现这次是 `C:\Users\<username>\AppData\Local\Microsoft` 目录又没权限访问。重复上述步骤添加权限后，顺利启动。问题解决。

虽然不知道是什么原因导致权限丢失，不过十有八九是 Bug 10 的某个补丁包干的好事。吔屎啦微软。