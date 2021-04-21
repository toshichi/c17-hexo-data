---
title: Nextcloud 新建用户报错
date: 2020-08-13 02:31
tags: [Nextcloud, 报错]
category: Services
id: nextcloud-new-user-error
cover: .images/Nextcloud%20新建用户报错/image-20200813023129134.png
---

Nextcloud 新建用户时，日志提示错误：

```
Call to a member function getSize() on bool
```

导致用户列表无法显示，且新用户无法登录。

原因是用户配额和 `quota_include_external_storage` 设置之间有冲突。

绕过方案为：

- 修改`/var/www/html/config/config.php`：

    ``` php
    ‘quota_include_external_storage’ => false,
    ```

- 此时用户列表可以显示，删除新建的出错用户

- 重新添加新用户，配额容量无限制

- 以新用户身份登陆一次，确认文件正常

- 将 `quota_include_external_storage` 改回去

- 根据需求限制新用户配额

此时新用户可正常使用。

当共享大量文件给新用户时，由于被共享文件也计入用户配额使用，因此可能提示配额超限。

此外如果共享文件的 owner 曾出现误报存储已满问题时，即使通过修改 `quota_include_external_storage` 解决，被共享用户在进入共享文件目录时也仍会提示其他用户存储满。暂时无法解决，无实际影响可忽略。

![image-20200813023129134](.images/Nextcloud%20新建用户报错/image-20200813023129134.png)