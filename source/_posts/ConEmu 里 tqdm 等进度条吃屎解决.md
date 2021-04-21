---
title: ConEmu 里 tqdm 等进度条吃屎解决
date: 2019-05-19 18:20
tags: [ConEmu, tqdm]
category: Windows
id: tqdm-sucks-in-conemu
cover: .images/ConEmu%20里%20tqdm%20等进度条吃屎解决/c937aa35.png
---

## 问题：

![c937aa35.png](.images/ConEmu%20里%20tqdm%20等进度条吃屎解决/c937aa35.png)

运行全横行进度条时，莫名换行，更改字体也无效。

## 解决：

是 ConEmu 的 RealConsole 的字体问题，不管 ConEmu 显示什么字体，都是在一对一映射一个隐藏的 RealConsole 的字体。

按 Ctrl+Alt+Win+Space 弹出 RealConsole，右键属性发现字体是新宋体：

![a2ac7518.png](.images/ConEmu%20里%20tqdm%20等进度条吃屎解决/a2ac7518.png)

新宋体无法正确显示进度条使用的方块字符。

首先在注册表 `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont` 中把新宋体改成一个正常的带中文的等宽字体，比如 `Sarasa Term` 系列

![856ef4f9.png](.images/ConEmu%20里%20tqdm%20等进度条吃屎解决/856ef4f9.png)

然后在 ConEmu 设置中，Feature 选项里点右侧 Show real console 旁边的省略号按钮，修改字体为正常字体。

![46a8b97f.png](.images/ConEmu%20里%20tqdm%20等进度条吃屎解决/46a8b97f.png)

好了，美滋滋。

![b45a736d.png](.images/ConEmu%20里%20tqdm%20等进度条吃屎解决/b45a736d.png)

参考官方帮助：
[ConEmu \| Unicode Support](https://conemu.github.io/en/UnicodeSupport.html)