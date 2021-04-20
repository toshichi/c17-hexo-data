---
title: 三星 Galaxy S6 保持 knox 0x0 的 root
date: 2015-06-11 16:48:25
tags: [Android, root, S6]
category: Hacking
id: sgs6-root
cover: .images/%E4%B8%89%E6%98%9F%20Galaxy%20S6%20%E4%BF%9D%E6%8C%81%20knox%200x0%20%E7%9A%84%20root/root-galaxy-without-tripping-knox-600x392.jpg
---
新入手三星 S6 公开版，按以往的经验 root 时线刷刷入第三方 rocovery 的过程中会导致 knox 0x1 从而失去保修。而且 S6 的国行有 BL 锁，解锁同样会失去保修。
发现 PingPongRoot 可以在不使用线刷动作的前提下获取 root 权限，从而保持 knox 0x0。
XDA 原帖地址：http://forum.xda-developers.com/galaxy-s6/general/root-pingpongroot-s6-root-tool-t3103016
首先下载原帖的附件 pingpongroot_beta6.apk 并安装。（百度网盘：http://pan.baidu.com/s/1c0ASLhA）
安装后启动会提示安装 Super SU，安装后打开 Super SU，不理会报错，然后退出之。重新进入 PingPong Root 点击 Download Data。更新完成后点 Get Root 即可自动完成 root。之后按提示重启手机即获得 root 权限。
但此法仍会导致系统设置内的状态变为“定制”，从而导致 OTA 失效。需要更新时用官方的 Smart Switch 线刷更新系统即可。或通过安装 Xposed 框架（官方不支持三星5.0，但可以通过其他办法刷入）再安装 Wanam Xposed 模块修改设备状态为官方。

在 SM-G9200 大陆公开版 G9200ZCU1AOE4 固件测试通过。