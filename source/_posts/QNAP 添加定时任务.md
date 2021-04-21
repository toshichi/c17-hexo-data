---
title: QNAP 添加定时任务
date: 2020-03-19 08:31
tags: [QNAP, crontab]
category: Hacking
id: qnap-crontab
cover: false
---

``` bash
sudo vi /etc/config/crontab
sudo crontab -l
crontab /etc/config/crontab && /etc/init.d/crond.sh restart
```

记得把要运行的命令属性 +x

参考：

[Add items to crontab](https://wiki.qnap.com/wiki/Add_items_to_crontab)