---
title: Ctrl+1 快捷键失效解决
date: 2021-10-31 15:10
tags: [IME, 快捷键]
category: Windows
id: ctrl-1-shortcut
cover: .images/Ctrl+1%E5%BF%AB%E6%8D%B7%E9%94%AE%E5%A4%B1%E6%95%88/image-20211031150600311.png
---

Ctrl + 1 的快捷键如果被莫名其妙占用，可能是 IME 快捷键中英语美国的默认快捷键无法释放导致。

如果添加后删除英语美国键盘布局，可能会出现此现象。

此时即使在键盘快捷键中删除英语美国的快捷键，或者将此键盘布局重新添加后再修改快捷键，也会反复发作。

![image-20211031150600311](.images/Ctrl+1%E5%BF%AB%E6%8D%B7%E9%94%AE%E5%A4%B1%E6%95%88/image-20211031150600311.png)

修改注册表 `HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\` 将所有00开头的8位数字 key 全部删除，然后重启，问题可能解决。

此时可以重新设置其他快捷键。

参考： [パソコン好きな人の独学ノート 入力言語のホットキーとレジストリ](http://7v.blog107.fc2.com/blog-entry-51.html)