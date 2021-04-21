---
title: Windows 远程桌面同时查看内容（shadow）
date: 2018-11-24 18:28
tags: [Windows, RDP, shadow]
category: Windows
id: windows-rdp-shadow
cover: .images/Windows%20远程桌面同时查看内容（shadow）/ab0de617.png
---

远程桌面连接中重复使用同一用户登录时，默认情况下新连接会顶掉旧连接。如果允许同一用户多重登陆，则会建立多个 session，并存。但多个 session 之间内容并不共享。
所以需要同时查看同一 session 的桌面时，就需要使用 shadow 方式查看已经连接的桌面。

以下操作均在 rdp 服务端进行

## 1 允许静默连接

组策略
`Computer Configuration\Administrative Templates\Windows Components\Remote Desktop Services\Remote Desktop Session Host\Connections\`
修改 `Set rules for remote control of Remote Desktop Services user sessions` 为 `Full control without user's permission`

![ab0de617.png](.images/Windows%20远程桌面同时查看内容（shadow）/ab0de617.png)

## 2 查看已经登陆的用户与 session

`qwinsta` 或者 `query session`

![e5c1fa31.png](.images/Windows%20远程桌面同时查看内容（shadow）/e5c1fa31.png)

## 3 连接到对应 session

管理员权限
``` cmd
mstsc /shadow:<id> /control /noconsentprompt
```

## 4 建立一个 bat 脚本

当一个 user 只能建立一个 session 时，使用用户名区分更方便。
使用管理员权限运行
``` bat
@echo off
for /f "tokens=3" %%a in ('qwinsta ^| find "%1"') do set id=%%a
mstsc /shadow:%id% /control /noconsentprompt
```