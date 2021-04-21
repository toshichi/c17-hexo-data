---
title: Nextcloud 误报存储已满
date: 2020-08-06 17:22
tags: [Nextcloud, 误报]
category: Services
id: nextcloud-storage-full
cover: .images/NextCloud%20误报存储已满/image-20200806172234483.png
---

在 Nextcloud 数据目录下 mount 其他位置的存储时，会误报存储已满。

问题原因在于统计文件大小时会将外部存储和被共享文件全部计入，而统计总容量时不计算外部存储和 mount 的其他位置。

修改`/var/www/html/config/config.php`，添加参数：

``` php
‘quota_include_external_storage’ => true,
```

并且在用户配置中，将配额改为“无限”以外的具体数值：

![image-20200806172234483](.images/NextCloud%20误报存储已满/image-20200806172234483.png)

设置后当前用户不再提示存储满，但如果此用户分享文件给其他用户，则被分享用户访问时仍会提醒文件 owner 的存储满。

此外，即使 UI 上不提示，但 Nextcloud 内部的判定依然是存储满，因此 File Versioning 会因为空间不足而不工作，目前没有找到解决方法。因此不推荐层叠 mount 方式存储。