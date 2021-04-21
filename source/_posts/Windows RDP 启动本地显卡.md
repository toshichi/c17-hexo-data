---
title: Windows RDP 启动本地显卡
date: 2018-07-26 18:28
tags: [Windows, RDP, 显卡]
category: Windows
id: windows-local-gpu
cover: false
---

使用管理员身份运行，可以使用 [Windows 批处理自动提权](:note:3ca143be-6360-4942-beaa-a45b2c6fccc5)

``` powershell
cd /d %~dp0
for /f "tokens=3" %%a in ('qwinsta ^| find "< user name >"') do set id=%%a
powershell Disconnect-RDUser -HostServer localhost -UnifiedSessionID %id% -Force
tscon %id% /DEST:console
wmic process call create "< program uses GPU >"
```

运行后 RDP 会断开，重连即可。注意提前在显卡驱动中将所需程序设为使用 GPU 运行。
其中第三行为主动断开 RDP，防止第四行被动断开后弹窗。