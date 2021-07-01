---
title: 小方摄像头破解 rtsp
date: 2021-05-24 03:15
updated: 2021-06-02 03:15
updated: 2021-06-26 09:18
tags: [RTSP]
category: Hacking
id: xiaofang-rtsp
cover: .images/%E5%B0%8F%E6%96%B9%E6%91%84%E5%83%8F%E5%A4%B4%E7%A0%B4%E8%A7%A3%20rtsp/image-20210524011143324.png
---

适用于第一代小方。并不复杂但坑很多。

## 1. 降级固件到 v3.0.3.56

-   参考 [fang-hacks wiki](https://github.com/samtap/fang-hacks/wiki/HowTo:-Flash-original-Xiaomi-firmware-from-sdcard-(factory-reset)) ，在 [mega](https://mega.nz/#!GBghwbpY!btf0jxHPFTPtifqNJNMHXEiRd3H5DkUtOJYOq8QpgfQ) 下载固件备份。（[镜像](https://drive.google.com/file/d/16aIyjI0jErisPT5XEQcB8m2o5WTMEUNy/view?usp=sharing)）
-   格式化 SD 卡为 FAT32 后将 `0.elf` 重命名为 `FIRMWARE_660R.bin`，复制到卡根目录。
-   插卡，用卡针按住 reset 同时摄像头上电，持续按住 15s 以上后松开。
-   等待刷机完成，黄灯闪烁或黄蓝灯交替闪烁。如果始终没有变化，保险起见约 10min 后重新拔插电源。
-   上电后如无语音提醒，按 reset 1s 左右，出现语音。
-   如果自始至终黄灯常亮无反应，尝试[此视频](https://www.youtube.com/watch?v=mpzPWYONWZA)描述中的第一个固件（[镜像](https://drive.google.com/file/d/1Edcn3XB8gDQHwLoGIVLkaxpp2uGbDGjb/view?usp=sharing)），过后再刷一次原固件。
-   如果反复尝试都没有反应，可能是过热等玄学问题，断电冷静一下可能就好了。

## 2. 连接 WiFi （二维码）

-   参考 [fang-hacks wiki](https://github.com/samtap/fang-hacks/wiki/Connecting-to-WiFi-without-using-Mi-Home) ，语音提示等待连接时，配置并扫描[二维码生成页面](https://codepen.io/ril3y/full/gXyzmO/)。扫描后提示正在连接，指示灯蓝黄交替，但可能不会提示连接成功。
-   如果灯持续交替闪烁，查看路由可见摄像头反复连接断开网络。此时重新拔插摄像头电源。
-   如果仍无改善，则暂时跳过，后面使用脚本设置。

## 3. 构建 SD 卡文件结构

-   下载 [fang-hacks 的 IMG 镜像](https://github.com/samtap/fang-hacks/releases)，使用 Win32DiskImager 或 balenaEtcher 等工具写入 SD 卡。卡不必过大，1G 即可。

-   写入完成后访问第一个 FAT32 分区（可能需要重新拔插读卡器），修改`bootstrap/fang_hacks.cfg` 

    ``` ini
    DISABLE_CLOUD=1
    NETWORK_MODE=1
    ```

    

## 4. 连接 WiFi (脚本)

-   如果前面连接网络失败，Clone [设置脚本](https://github.com/davidjb/fang-wlan-setup) 到分区根目录，备份原有 `snx_autorun.sh` 并覆盖之
-   编辑 `.wifipasswd`  和 `.wifissid` 写入网络信息
-   摄像头不插卡上电，等待半分钟确定启动完毕后插入卡，会出现提示音，等待半分钟后断电并拔卡后重新上电
-   等待 WiFi 连接完成，此时蓝灯闪烁，在路由器中查看摄像头的 IP
-   在电脑中访问 SD 卡的 FAT32 分区，恢复`snx_autorun.sh` ，并可删除设置脚本的其他文件

## 5. 执行破解脚本

-   和4的倒数第三步相同，摄像头状态稳定后插入卡，听到提示音之后，访问 `http://device-ip/cgi-bin/status`

![image-20210524011143324](.images/%E5%B0%8F%E6%96%B9%E6%91%84%E5%83%8F%E5%A4%B4%E7%A0%B4%E8%A7%A3%20rtsp/image-20210524011143324.png)

-   点击 Apply 执行脚本

![image-20210523210054928](.images/%E5%B0%8F%E6%96%B9%E6%91%84%E5%83%8F%E5%A4%B4%E7%A0%B4%E8%A7%A3%20rtsp/image-20210523210054928.png)

-   执行完成后点击 back，此时应可使用 `root` 和密码 `ismart12` SSH 连接 22 端口

## 6. 切断公网访问后的时间服务器设置

出于对中国网络服务的不信任，在路由器上切断摄像头的公网访问。此时时间不能同步，需要在内网架设一个 NTP 时间服务器，并修改部分脚本参数。

-   `vi /media/mmcblk0p2/data/etc/scripts/02-ntpd` 修改第三行的 time.google.com 为内网服务器地址
-   `vi /media/mmcblk0p1/bootstrap/www/action` 修改 155 行的地址

## 7. 其他

![image-20210523210544967](.images/%E5%B0%8F%E6%96%B9%E6%91%84%E5%83%8F%E5%A4%B4%E7%A0%B4%E8%A7%A3%20rtsp/image-20210523210544967.png)

千万不要手贱点击 Expend data partition 后的 Yes ，根据 [Release Note](https://github.com/samtap/fang-hacks/releases)，此处有一个已知问题，重启后将耗费非常长的时间调整分区，此时可能亮黄灯并且没有网络连接，完成后可能也没有任何提示，注意不要中途断电。我等待了一小时后断电，插入电脑发现分区调整已经完成，但插回摄像头黄灯常亮无法启动，被迫从第一步恢复固件开始重试。因此不推荐进行此操作。

## 8. RTSP

RTSP 地址为 `rtsp://device-ip/unicast`， 可以接入 ZoneMinder 或 Shinobi 等监视服务器，也可使用 MPC 和 PotPlayer 等播放器观看直播

### 8.1 RTSP 守护进程

RTSP 进程不太稳定，过一段时间之后查看经常显示红色 NOK，需要手动禁用后启用再重启服务才能恢复，因此需要一个守护进程自动重启。

参考[这个 issue](https://github.com/samtap/fang-hacks/issues/217) 和其中提到的 [bobby 的这篇文章](http://bobbyromeo.com/home-automation/xiaomi-smart-1080p-wifi-ip-camera-rtsp-streaming-hack/#rtsp_check) （文中还提到了翻转影像等，可以参考）
-   在`/media/mmcblk0p2/data/usr/bin` 创建 `rtsp-check.sh`

-   ``` bash
    #!/bin/sh
     
    while true; do
    if pgrep -x "snx_rtsp_server" > /dev/null
    then
        :
    else
        /media/mmcblk0p2/data/etc/scripts/20-rtsp-server start
    fi
    sleep 2
    done
    ```

-   添加执行权限 `chmod +x rtsp-check.sh`

-   在 `/media/mmcblk0p2/data/etc/scripts` 创建服务文件 `99-rtsp-check`

-   ``` bash
    #!/bin/sh
    PIDFILE="/var/run/rtsp-check.pid"
     
    status()
    {
      pid="$(cat "$PIDFILE" 2>/dev/null)"
      if [ "$pid" ]; then
        kill -0 "$pid" >/dev/null && echo "PID: $pid" || return 1
      fi
    }
     
    start()
    {
      echo "Starting rtsp-check script..."
      rtsp-check.sh </dev/null >/dev/null 2>&1 &
      echo "$!" > "$PIDFILE"
    }
     
    stop()
    {
      pid="$(cat "$PIDFILE" 2>/dev/null)"
      if [ "$pid" ]; then
         kill $pid || rm "$PIDFILE"
      fi
    }
     
    if [ $# -eq 0 ]; then
      start
    else
      case $1 in start|stop|status)
        $1
        ;;
      esac
    fi
    ```

-   之后在 Manage Scripts 页面即可看到新添加的 `99-rtsp-check` 服务，启动之即可监视并自动重启挂掉的 RSTP 服务（刚启动时所有服务的PID基本临近，如果发现 RTSP 的 PID 显著变大，则说明已经被重启过）

    ![image-20210626091639347](.images/%E5%B0%8F%E6%96%B9%E6%91%84%E5%83%8F%E5%A4%B4%E7%A0%B4%E8%A7%A3%20rtsp/image-20210626091639347.png)

## 9. OSD 时间显示

参考 [wiki](https://github.com/samtap/fang-hacks/wiki/Controlling-the-text-overlay) 和 [Gitter](https://gitter.im/fang-hacks/Lobby?at=59d26cd9177fb9fe7e2d010c) 

-   下载 [`snx_isp_ctl`](https://mega.nz/#!r1AGVCpZ!sJvjRdjCvu8nNWloYGaUyn_0uDM1eYG7yB6TaRfeLVI) （[镜像](https://drive.google.com/file/d/1Jj5mZDFfsEMe29CED6ch74DFxgtpiJRJ/view?usp=sharing)），复制到 `/media/mmcblk0p2/data/usr/bin`，加上执行权限

-   编辑 `/media/mmcblk0p2/data/etc/scripts/20-rtsp-server` 脚本，在 start 函数倒数第二行添加：

    ``` bash
    snx_isp_ctl --osdset-en 1 --osdset-ts 1 --osdset-template 1234567890./-:Date --osdset-gain 2 --osdset-bgtransp 0x1 --osdset-bgcolor 0x000000 --osdset-position 0,-31
    ```

    其中最后的 `--osdset-position 0,-31` 用于调节 OSD 显示在左上角，去除开头的空行。如果显示出现问题可以调大 -31 的值。

## 10. 时区设置

-   在网页上修改时区，格式参照 [ICANN](https://mm.icann.org/pipermail/tz/2016-April/023570.html) 的页面，日本时区为 `JST-9` ，中国时区为 `CST-8` 。

-   此时系统时间正确，但 OSD 使用硬件时间，仍然是 UTC 时区，此处参考[这个 issue](https://github.com/samtap/fang-hacks/issues/78)，修改`/media/mmcblk0p2/data/etc/scripts/02-ntpd`，在 start 函数插入一行 `ntpd -q -n $NTPD_OPTS && hwclock -t`，变为如下代码：

    ``` sh
    start() 
    {
      echo "Starting ntpd..."
      ntpd -q -n $NTPD_OPTS && hwclock -t
      ntpd $NTPD_OPTS
    }
    ```

-   重启摄像头，OSD 时间与系统时间均正确显示

    ![image-20210602031336997](.images/%E5%B0%8F%E6%96%B9%E6%91%84%E5%83%8F%E5%A4%B4%E7%A0%B4%E8%A7%A3%20rtsp/image-20210602031336997.png)
