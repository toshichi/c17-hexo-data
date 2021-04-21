---
title: 安装 mosh 与 byobu
date: 2019-11-24 22:02
tags: [Linux, mosh, byobu]
category: Linux
id: install-mosh-byobu
cover: .images/%E5%AE%89%E8%A3%85%20mosh%20%E4%B8%8E%20byobu/image-20210421235258827.png
---

## 1 mosh

在延迟过高的服务器上操作时，使用 mosh 来通过 UDP 连接加强体验。甚至网络中断后重连或系统休眠后仍能维持连接。
默认使用 60000 以上端口，一个 UDP 只能有一个连接。
此处配置成和 ssh 使用相同端口来方便连接。

``` bash
sudo apt install mosh
```

连接时： 

```bash
mosh -p <mosh port> --ssh='ssh -p <ssh port>' <user>@<server address>
```

### 1.1 WinSCP 中使用 mosh

``` bash
mosh -p !# --ssh='ssh -p !#' !U@!@
```

### 1.2 端口转发注意点

因为 mosh 所使用的端口是客户端连接时指定的，所以不能转发到不同的端口。
比如通过把服务器的 60001 UDP 转发到 50001，再使用 mosh -p 50001，是无法连接的。
需要转发到相同端口连接。
为避免麻烦，使用与转发的 ssh TCP 端口相同的端口即可。

## 2 byobu

mosh 单一端口只支持一个连接，所以要多线操作时不方便使用多连接的方式，因此需要分屏操作。
tmux 快捷键十分反人类，难以记忆，得不偿失。虽然可以修改，但往往使用 docker 或公用服务器时一一修改非常麻烦。
因此选择默认快捷键适合人类使用的 byobu。byobu 是日语びょうぶ屏風。
byobu 可以选择基于 tmux 后端还是 screen 后端。使用 `byobu-select-backend` 进行切换。
一般 ubuntu 会内置 byobu，非常方便。

### 2.1 快捷键

F2 新建 Window， F3 F4 移动到 Window
Shift F2 上下分割，Ctrl F2 左右分割
Shift F3 F4 移动到分屏，Ctrl F6 关闭当前分屏
Shift + 方向键 移动到分屏
F5 重载配置文件，Shift F5 似乎是切换状态栏
F6 Detach session
F7 滚动模式，按 pgup pgdn 滚屏，回车退出
Alt + pgup/pgdn 直接滚屏
F8 修改 Window 名
F9 配置，Shift + F12 切换F键有效性
Shift + F11 最大化当前窗口

### 2.2 时间换行问题

有时状态栏最后一位时间会换行，导致状态栏错位。这是因为当前终端字体不支持系统 logo 的特殊字符显示。按 F9 进配置，选择 `Toggle status notifications`，去掉 logo，Apply 即可。

### 2.3 提示符风格

默认配色不是默认配色，使用 `byobu-disable-prompt` 恢复默认。

### 2.4 256色不支持

部分版本切换到默认配色时会不支持 256 色，`echo $TERM` 返回 `screen`。
这是默认 tmux 配置的问题。

``` bash
sudo vim $BYOBU_PREFIX/share/byobu/profiles/tmux
```

查找 `set -g default-terminal "screenr"` 修改为 `set -g default-terminal "screen-256color"`

### 2.5 支持滚轮和鼠标

Alt + F12 切换鼠标支持

![image-20210421235258827](.images/%E5%AE%89%E8%A3%85%20mosh%20%E4%B8%8E%20byobu/image-20210421235258827.png)