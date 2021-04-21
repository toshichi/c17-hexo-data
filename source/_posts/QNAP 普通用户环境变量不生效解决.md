---
title: QNAP 普通用户环境变量不生效解决
date: 2020-08-02 23:55
tags: [QNAP, 环境变量]
category: Hacking
id: qnap-env-var
cover: false
---

内置 admin 用户的 home 位于 `/root` ，而新建用户的 home 位于 `/share/homes/USERNAME`。此目录缺乏各种 rc 文件。导致安装 opkg 等第三方工具时无法自动设置 path。

解决方案为使用普通用户登录 SSH 并定位到 home，然后把 root 目录里的各种配置文件软链接过来。

``` bash
ln -s /root/.bash_logout .bash_logout
ln -s /root/.bash_profile .bash_profile
ln -s /root/.bashrc .bashrc
ln -s /root/.profile .profile
```

修改后普通用户的 prompt 也会变成 `#` ，非常迷惑，原因是 PS1 变量在 `.profile` 中被修改，`sudo vim .profile` 编辑该文件，注释掉第一行的修改语句即可。

``` bash
# export PS1='[\w] # '
reset
source /opt/etc/profile
```

威联通的系统似乎没有考虑过建立普通用户日常使用的问题，默认思维模式都是使用内置 admin 账户完成，软件质量比较一般。

