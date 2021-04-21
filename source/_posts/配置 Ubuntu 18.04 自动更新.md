---
title: 配置 Ubuntu 18.04 自动更新
date: 2019-11-17 00:17
tags: [Linux, Ubuntu, 自动更新]
category: Linux
id: ubuntu-1804-autoupdate
cover: .images/配置%20Ubuntu%2018.04%20自动更新/image-20191117001230583.png
---

``` bash
sudo apt install unattended-upgrades
sudo vim /etc/apt/apt.conf.d/50unattended-upgrades
```

去掉 update 一行前的注释，并修改自动清除未用包的设置。

``` config
"${distro_id}:${distro_codename}-updates";
...
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
```

![image-20191117001230583](.images/配置%20Ubuntu%2018.04%20自动更新/image-20191117001230583.png)

然后修改重启配置：

``` bash
sudo vim /etc/apt/apt.conf.d/20auto-upgrades
```

``` config
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

最后测试运行，确认生效：

``` bash
sudo unattended-upgrades –dry-run –debug
```

