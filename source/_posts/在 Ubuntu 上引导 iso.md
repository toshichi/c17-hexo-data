---
title: 在 Ubuntu VPS 上引导 iso 安装纯净系统
date: 2019-09-20
tags: [Ubuntu, 腾讯云, 引导 iso, VPS]
category: Linux
id: vps-boot-from-iso
cover: .images/%E5%9C%A8%20Ubuntu%20%E4%B8%8A%E5%BC%95%E5%AF%BC%20iso/image-20210421212105375.png
---

租用 VPS 厂商的机器时，一般只能预装厂商原有的镜像。有时镜像并不纯净，厂商会在里面加料。因此需要安装原版系统。下面以腾讯云重新安装 Ubuntu 18.04 LTS 为例。

## 1. 检测系统环境

### 1.1 确定系统有 grub

``` shell
cat /boot/grub/grub.cfg
```

### 1.2 确认分区布局

``` shell
df -h
```

查看 `/`  和 `/boot` 目录是否在不同分区。如果仅有根目录，处理较为容易，否则在后续步骤中需要注意。

## 2. 下载系统镜像

注意：Ubuntu 如果使用常规 iso，安装会报错，因此使用网络安装版（Network installer）的iso。

``` shell
sudo wget -O /boot/isoboot.iso http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/mini.iso
```

## 3. 准备 Memdisk

原理是将 iso 镜像读入内存。使用 apt 安装 Syslinux：

``` shell
sudo apt install syslinux -y
```

复制 memdisk 文件到引导目录：

``` shell
sudo cp -f /usr/lib/syslinux/memdisk /boot/memdisk
```

## 4. 修改 Grub 引导

``` shell
sudo vim /etc/grub.d/41_custom
```

插入以下内容到 EOF 之前：

``` shell
menuentry 'OS Web Install' {
    insmod part_msdos
        insmod part_gpt
        insmod ext2
    set root=(hd0,msdos1)
    echo 'Loading memdisk ...'
    linux16 /boot/memdisk raw iso
    echo 'Loading ISO ...'
    initrd16 /boot/isoboot.iso
    echo 'Booting ISO ...'
}
```

注意，此处根据刚才分析分区布局时候的结果而有所不同：

>   - 如果你的服务器是单块硬盘，而且只有一个分区，那么root的值为 **(hd0,msdos1)**
>   - 如果你的服务器的单块硬盘，存在不止一个分区，看 /boot 分区在哪个盘上，比如在 /dev/vda5 上，那就是 **(hd0,msdos5)**
>   - 其他更复杂的情况，重启服务器，到达 Grub 界面时按下 **C** 键，进入 Grub 命令行，并按照以下步骤操作：
>

``` shell
grub> ls
(hd0) (hd0,msdos1) (hd0,msdos5)
grub> ls (hd0,msdos1)/
error: unknown filesystem. # 说明这个分区不是正确的启动分区，继续尝试
grub> ls (hd0,msdos5)/
lost+found/ etc/ (各种文件夹) # 说明这个分区是正确的启动分区

reboot #回到系统
```

修改 `/etc/default/grub` 配置文件增大 `GRUB_TIMEOUT` 超时时间，然后更新 Grub 配置：

``` shell
update-grub
```

之后确认是否正确写入：

``` shell
cat /boot/grub/grub.cfg
```

## 5. 备份配置

备份网络配置等

``` shell
cat /etc/netplan/50-cloud-init.yaml
```

## 6. 重装

重启，使用 VNC 连接，启动时选择 **OS Web Install** 并操作重装。

因为使用的是最小镜像，需要联网下载大量安装包，过程可能比较漫长，耐心等待即可。

![image-20210421212105375](.images/%E5%9C%A8%20Ubuntu%20%E4%B8%8A%E5%BC%95%E5%AF%BC%20iso/image-20210421212105375.png)

-------

参考：

https://blog.ilemonrain.com/linux/grub-memdisk-boot-iso.html

https://www.imbeee.com/2017/12/10/install-pure-system-on-vps-and-encrypt-it/