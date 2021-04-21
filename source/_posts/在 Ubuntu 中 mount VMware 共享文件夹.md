---
title: 在 Ubuntu 中 mount VMware 共享文件夹
date: 2019-05-22 21:30
tags: [Ubuntu, VMware, 共享文件夹]
category: Linux
id: mount-vmware-shared-folder
cover: false
---

## 1. 安装 VMware Tools

- 给虚拟机增加一个光驱

- `VM> Install VMware Tools`

- 手动安装

    ``` bash
    sudo mkdir /mnt/cdrom
    sudo mount /dev/cdrom /mnt/cdrom
    tar xzvf /mnt/cdrom/VMwareTools-x.x.x-xxxx.tar.gz -C /tmp/
    cd /tmp/vmware-tools-distrib/
    sudo ./vmware-install.pl -d
    sudo reboot
    ```

- 可以删掉光驱

## 2. 映射共享文件夹

- 查看 `/mnt/hgfs` 目录下是否已有映射的目录
- 如果没有，`/usr/bin/vmware-config-tools.pl`
