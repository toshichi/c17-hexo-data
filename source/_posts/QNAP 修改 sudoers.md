---
title: QNAP 修改 sudoers
date: 2020-03-16 04:50
tags: [QNAP, sudoers]
category: Hacking
id: qnap-mod-sudoers
cover: false
---

威联通 NAS 默认 sudoers 仅包括内置 admin 账户，修改时需要编辑 `/usr/etc/sudoers` 文件。

但 `/usr/etc` 目录中的编辑在重启后均会复原。因此需要在`系统设置->硬件`中打开允许 `autorun.sh` 运行选项，并且编辑该文件。

```bash
mount $(/sbin/hal_app --get_boot_pd port_id=0)6 /tmp/config
vim /tmp/config/autorun.sh
```

```bash
#!/bin/bash
mkdir -p /usr/etc/sudoers.d
echo "Tojo ALL=(ALL) ALL" > /usr/etc/sudoers.d/Tojo
```

如此即可在重启后自动修改 sudoers。如果直接向 `/usr/etc/sudoers` 末尾写入配置的话，由于该配置文件最后一行为 include 命令，因此会导致在此之后写入的配置无法生效。因此选择向其加载的配置目录中写入新文件。