---
title: WinSCP 使用外部工具连接 ssh
date: 2018-11-27 18:12
tags: [WinSCP, ssh]
category: Windows
id: winscp-ssh-tool
cover: .images/WinSCP%20使用外部工具连接%20ssh/71f2b46d.png
---

## WSL bash + ConEmu

![71f2b46d.png](.images/WinSCP%20使用外部工具连接%20ssh/71f2b46d.png)

``` bash
"C:\Program Files\ConEmu\ConEmu64.exe" -run bash.exe -cur_console:c -c "ssh !U@!@ -p !#" -new_console:p5
```

## WSL bash + cmd

``` bash
"C:\Windows\System32\cmd.exe" /k "C:\Windows\Sysnative\bash.exe -c ^"mosh -p !# --ssh=^'ssh -p !#^' !U@!@^""
```