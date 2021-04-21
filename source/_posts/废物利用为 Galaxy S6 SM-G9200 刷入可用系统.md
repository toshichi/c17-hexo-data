---
title: 废物利用为 Galaxy S6 SM-G9200 刷入可用系统
date: 2020-04-25
tags: [Galaxy S6, SM-G9200, 刷机, Android]
category: Hacking
id: galaxy-s6-system
cover: .images/废物利用为%20Galaxy%20S6%20SM-G9200%20刷入可用系统/image-20200425054145843.png
---

Galaxy S6 发布于2015年，中国大陆公开版是双卡单4G，初始系统版本 5.0。我将其作为备用机多年来一直使用当年自行修改的旧版 6.0 系统，时过境迁现在已兼容性较差。三星已经发布了7.0版本的系统更新，因此试图更新到最新版本的 offical 系统。但中国版系统阉割严重，且有大量中国毒瘤App，无法直接使用。

尝试 Odin 刷入港版系统，不管是四件套还是一体包，单刷还是全部，均会验证失败。查阅得知该型号虽然港版和中国（内地，下略）版均标示型号为`SM-G9200`，但港版机型代号为`zerofltezh`，中国版为`zerofltezc`，基带不同，港版不支持中国电信网络，因此无法混刷。

故底包只能采用中国版官方固件。在此基础上刷入 GApps 使手机可用。

## 1. 刷入完整系统

使用 [`SamFirm`](https://samfirmtool.com/) 下载最新版`CHC`区域固件四件套：

![image-20200425054145843](.images/废物利用为%20Galaxy%20S6%20SM-G9200%20刷入可用系统/image-20200425054145843.png)

使用最新版 `Odin` 刷入手机，重启，确认正常动作。

## 2. 刷入  CF-Auto-Root

在 [其网站主页](https://desktop.firmware.mobi/) 输入型号G9200后，选择 `zerofltezc` 版本：

![image-20200425054507054](.images/废物利用为%20Galaxy%20S6%20SM-G9200%20刷入可用系统/image-20200425054507054.png)

点击最新固件，在其下载页面单击 Configure：

![image-20200425054555517](.images/废物利用为%20Galaxy%20S6%20SM-G9200%20刷入可用系统/image-20200425054555517.png)

在配置选项中，`Installation type` 选择 `Systemless Image`，`Advanced Encryption Options` 中 `dm-verify` 选择 `Remove` ，其他保持默认，点击 `Generate` 生成刷机镜像，可能需要排队，且下载速度较慢。

下载后使用 Odin 在 AP 中刷入手机，重启，确认正常动作。

## 3. 刷入 Magisk

SuperSU 作者已经弃坑不再更新，当前使用 [`Magisk`](https://github.com/topjohnwu/Magisk) 管理SU权限。但我们目前没有安装 custom recovery，故不使用 zip 包直接安装，而采用 patch 系统镜像并用 Odin 刷入的方式安装。

1. 在 GitHub Release 页面获取最新的 `Magisk Manager` 并安装。
2. 使用 `7-zip` 打开 rom 四件套中的 AP 文件，解压其中 `boot.img` 并复制到手机中。
3. 运行 `Magisk Manager` ，点击安装 Magisk，选择 Patch 镜像，并继续在文件浏览中选择刚才提取的 `boot.img`。（注：根据官方文档，可以选择 Patch boot 或者 recovery，但测试 recovery 不成功，故此处采用 boot）
4. 将 patch 过后的 IMG 文件复制回电脑，更名为 `boot.img`，并使用 `7-zip` 等压缩软件打包为 tar 格式。
5. 在 Odin 的 AP 中选中刚才打包的 tar 包，刷入手机。
6. 重启，进入 `Magisk Manager` ，选择同意下载安装，再次重启后确认正常动作。

## 4. 刷入修改版 TWRP recovery

TWRP 没有正式提供 G9200 版本的支持。多年前 [Xiao1u](https://www.weibo.com/1649111590) 曾提供过修改过的兼容版本 `G9200-PC1-TWRP-3.0-PC1-0324.tar` ，搜索即可获得，此版本对 7.0 系统的兼容不完美，有可能会导致 bootloop。参考 [J Tech board 的解决方案](https://jtechboard.blogspot.com/2017/09/galaxy-s6-sm-g9200-china-model.html)，在确认 `dm-verify` 已关闭后，使用 Odin 刷入该文件。刷入时取消 Odin 中 Auto Reboot 的勾选。刷完后使用 Vol+ Home Pow 三键进入 recovery，什么都不做直接选择重启到系统，询问是否阻止系统还原 Recovery 时选择忽略。确认依然能正常进入系统。

## 5. 删除自带的中国 App 和字体等

如果不删除，后面刷入 GApps 可能导致系统空间不足。即使删除后仍要使用，可以事后重新安装到用户空间。

安装 [System App Remover](https://apkpure.com/jp/system-app-remover-root-needed/com.jumobile.manager.systemapp) 查看想要移除的内置应用，长按可以获得该应用的路径。使用 [Solid Explorer](https://apkpure.com/solid-explorer-file-manager/pl.solidexplorer2) 定位并删除文件。

## 6. 刷入 Gapps

在 [OpenGapps](https://opengapps.org/) 的主页获得 zip 刷机包，传输至手机，重启至 TWRP 后选择刷入。注意此处如果直接刷入 7.0 系统对应的 nano 或者 pico 包，[会导致系统 WebView 被删除](https://github.com/opengapps/opengapps/issues/724#issuecomment-497997441)，从而导致 Google 账户无法登录等问题，无法使用。

解决方案有两个思路，一是安装新的 Chrome WebView 替代被删除的原生 WebView，二是避免原生 WebView 被删除。经测试，即使安装Chrome 也仍然不能恢复该组件正常使用，可能三星对允许使用的 WebView 做了限制，或有其他兼容性问题。避免 WebView 被删除则可以通过[添加配置文件](https://github.com/opengapps/opengapps/wiki/Advanced-Features-and-Options) ，或者[添加 package-overlay 重新编译](https://github.com/opengapps/opengapps/issues/724#issuecomment-498086440) 等方法。这里使用相对比较简单的[修改安装脚本](https://github.com/opengapps/opengapps/issues/724#issuecomment-612578593)方式完成。

下载 pico 版本 OpenGApps zip 包后，解压提取 `install.sh` 文件，搜索：

``` shell
# List of GApps files that should NOT be automatically removed as they are also included in (many) ROMs removal_bypass_list
```

并在其后的空引号内加入 `WebViewGoogle`，保存退出，将修改后的文件压入 zip 包，重启手机进入 TWRP 刷入即可。

刷好后清空缓存，进入系统开发者模式，查看 “实装的 WebView” 选项不为空，即可。推荐重启手机，双清后从向导开始重新初始化系统，避免谷歌系列服务出现授权问题。

## 7. 总结

避免购买在中国大陆境内售卖的任何具有中国定制 Rom 的电子产品（包括无线耳机等具有中国区定制 Firmware 的产品），并 7x24 连接**全球互联网**，和全球大多数国家和地区的用户保持类似的软件使用习惯，可以避免绝大多数的烦恼。

