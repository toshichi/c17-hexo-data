---
title: QNAP 硬盘不休眠解决
date: 2020-03-19 08:33
tags: [QNAP, 硬盘, 休眠]
category: Hacking
id: qnap-hdd-wont-sleep
cover: false
---

## 0. 系统 raid 结构

使用 `cat /proc/mdstat` 可以查看所有 raid 卷。

```
Personalities : [linear] [raid0] [raid1] [raid10] [raid6] [raid5] [raid4] [multipath]
md3 : active raid1 sdc3[0]
      3897063616 blocks super 1.0 [1/1] [U]

md2 : active raid1 sda3[0]
      7804071616 blocks super 1.0 [1/1] [U]

md1 : active raid1 sdb3[0]
      392120832 blocks super 1.0 [1/1] [U]

md322 : active raid1 sda5[1] sdc5[0]
      7235136 blocks super 1.0 [2/2] [UU]
      bitmap: 0/1 pages [0KB], 65536KB chunk

md256 : active raid1 sda2[1] sdc2[0]
      530112 blocks super 1.0 [2/2] [UU]
      bitmap: 0/1 pages [0KB], 65536KB chunk

md321 : active raid1 sdb5[0]
      8283712 blocks super 1.0 [2/1] [U_]
      bitmap: 0/1 pages [0KB], 65536KB chunk

md13 : active raid1 sda4[0] sdc4[33] sdb4[32]
      458880 blocks super 1.0 [32/3] [UUU_____________________________]
      bitmap: 1/1 pages [4KB], 65536KB chunk

md9 : active raid1 sda1[0] sdc1[33] sdb1[32]
      530048 blocks super 1.0 [32/3] [UUU_____________________________]
      bitmap: 1/1 pages [4KB], 65536KB chunk

unused devices: <none>
```

注意到 md9 md13 md322 md256 均是横跨了机械硬盘的 raid 卷。搜索后得知 md9 和 md13 是系统自动创建的跨所有硬盘的 raid1 数据卷，存储系统配置和目录等。md322 和 md256 是系统 swap 分区。

## 1. 系统分区 raid 反复读取

使用 [blkdevMonitor.sh](https://drive.google.com/file/d/0B8u8qWRYVhv0S1ozWFRjazFEX1E/view) 脚本查看硬盘读写，可以看到大量 md9 相关读取。因此首先处理 md9 和 md13。

使用 `parted /dev/sdb print` 命令查看各硬盘，通过容量判断 sdb 是 SSD，sda 和 sdc 是两块机械硬盘。因此将 SSD 以外的硬盘从阵列中踢出。

``` bash
#!/bin/bash

echo "Disconnecting md9"
mdadm /dev/md9 --fail /dev/sda1
mdadm /dev/md9 --fail /dev/sdc1

echo "Disconnecting md13"
mdadm /dev/md13 --fail /dev/sda4
mdadm /dev/md13 --fail /dev/sdc4
```

使用 `mdadm -D /dev/md9` 验证移除是否成功

然后使用 `hdparm -y /dev/sda` 立即休眠硬盘，并使用 `hdparm -C /dev/sda`查看硬盘状态，`active/idle` 或者 `standby`

但断开连接时万一系统盘损坏，则系统数据会丢失，因此每天同步一次。使用下列脚本恢复连接。

``` bash
#!/bin/bash

echo "Re-adding md9"
mdadm /dev/md9 --re-add /dev/sda1
mdadm /dev/md9 --re-add /dev/sdc1

echo "Re-adding md13"
mdadm /dev/md13 --re-add /dev/sda4
mdadm /dev/md13 --re-add /dev/sdc4
```

保存上述两个脚本后（记得添加 x 权限），使用 crontab 每天运行一次，加回去15分钟后断开连接，应足够其完成同步。

``` bash
sudo echo 15 0 \* \* \* /share/homes/Tojo/rebuild_internal_raid.sh >> /etc/config/crontab
sudo echo 30 0 \* \* \* /share/homes/Tojo/disconnect_internal_raid.sh >> /etc/config/crontab
sudo crontab /etc/config/crontab && sudo /etc/init.d/crond.sh restart
```

并修改启动脚本使其自动生效。

## 2. swap 分区

使用 `cat /proc/swaps` 查看系统 swap 分区，发现很诡异地两个 swap 都建立在机械硬盘上。

但目前看起来不是很影响休眠，就先不管他了。



参考：

[Advanced guide to how I completely silenced my TS-453A - QNAP NAS Community Forum](https://forum.qnap.com/viewtopic.php?f=55&t=130788)

[md clarification please_ - QNAP NAS Community Forum](https://forum.qnap.com/viewtopic.php?t=114286)

[Find out which process prevents the hard drives from spindown - QNAPedia](https://wiki.qnap.com/wiki/Find_out_which_process_prevents_the_hard_drives_from_spindown)

