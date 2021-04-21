---
title: Nextcloud 自动扫描硬盘文件更新
date: 2020-08-06 15:18
tags: [Nextcloud, 扫描硬盘]
category: Services
id: nextcloud-auto-scan
cover: false
---

Nextcloud 如果直接在数据目录进行读写文件，Web UI 上不会显示文件的实时更新。解决方案有三种。

## 1. 手动扫描更新

在命令行使用 `php occ files:scan --all` 手动扫描。在 docker 中执行需要用：

``` bash
su -s /bin/bash -c "php /var/www/html/occ files:scan --all" -g users www-data
```

其中 -g 后的参数依次为分组名和用户名。

## 2. 修改 config.php 自动扫描

修改`/var/www/html/config/config.php`，添加参数：

``` php
'filesystem_check_changes' => true,
```

实现自动扫描

## 3. 使用外部存储

将需要直接读写的目录分离，并使用外部存储功能挂载。缺点是外部存储由插件实现，时常有 bug 出现。



参考：

https://help.nextcloud.com/t/folders-and-filesystem-check-changes/8203

https://it.ismy.fun/2018/11/12/nextcloud-auto-files-scan/

https://unix.stackexchange.com/questions/372850/how-to-run-command-as-different-user