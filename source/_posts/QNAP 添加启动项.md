---
title: QNAP 添加启动项
date: 2020-03-13 03:04
tags: [QNAP, 启动项, autorun]
category: Hacking
id: qnap-startup
cover: false
---

在`系统设置->硬件`中打开允许 `autorun.sh` 运行选项，并且编辑该文件。

```bash
mount $(/sbin/hal_app --get_boot_pd port_id=0)6 /tmp/config
or sudo mount $(sudo /sbin/hal_app --get_boot_pd port_id=0)6 /tmp/config
vim /tmp/config/autorun.sh
```

必须添加 shebang，否则会报错。

```bash
#!/bin/bash

```

参考：

[Running Your Own Application at Startup](https://wiki.qnap.com/wiki/Running_Your_Own_Application_at_Startup)

