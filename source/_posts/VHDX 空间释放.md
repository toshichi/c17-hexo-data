---
title: VHDX 空间释放
date: 2020-04-09 12:21
tags: [VHDX, 空间释放]
category: Windows
id: vhdx-release
cover: false
---

动态磁盘不会自动释放，因此如果有需要可以手动释放。似乎 exFat 分区效果不佳。

如果虚拟磁盘已经挂载，需要先卸载。然后运行 `diskpart`，执行：

``` diskpart
select vdisk file="<Path to VHDX>"
attach vdisk readonly
compact vdisk
detach vdisk
```

参考：

[https://blog.littlelanmoe.com/杂谈/364](https://blog.littlelanmoe.com/杂谈/364)