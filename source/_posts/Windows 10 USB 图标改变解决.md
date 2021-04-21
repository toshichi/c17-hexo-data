---
title: Windows 10 USB 图标改变解决
date: 2020-08-24
tags: [Windows 10, 图标]
category: Windows
id: windows-10-usb-icon-fix
cover: .images/Windows%2010%20USB%20图标改变解决/image-20200824200746369.png
---

Windows 的驱动服务器在 2019 年 11 月左右出现了一次 bug 导致所有的U盘图标均变为机柜，即使使用 `autorun.inf` 修改磁盘图标也无法生效，且单击弹出磁盘时，所有的设备名均变为 Device。

![20191110175553](.images/Windows%2010%20USB%20图标改变解决/20191110175553.png)

原因是 Windows 会联网获取设备驱动与图标，因此服务器端问题会影响本机驱动。驱动服务器问题后来已经修复，但本机已经下载的 USB 驱动还在，因此问题会残留。解决方案是删除已缓存的驱动程序。

- 打开 `C:\ProgramData\Microsoft\Windows\DeviceMetadataCache\dmrccache\en-us` 如果目录下有文件，寻找在其中 `DeviceInformation` 目录中含有 `ico2001.ico` 的机柜图标的目录，并删除该目录。

- 重启

- 如果没有恢复，或者上述目录中没有文件，则打开控制面板，设备和打印机，删除最下面的无法识别的 Device

    ![image-20200824195700272](.images/Windows%2010%20USB%20图标改变解决/image-20200824195700272.png)

- 重新插拔设备，应该可以恢复。此时查看上述目录，应该已经没有文件存在。弹出磁盘的菜单也应恢复显示设备名。

    ![image-20200824195842372](.images/Windows%2010%20USB%20图标改变解决/image-20200824195842372.png)  ![image-20200824200746369](.images/Windows%2010%20USB%20图标改变解决/image-20200824200746369.png)



参考/图片：<https://noushibou.hatenadiary.jp/entry/2019/11/10/101358>