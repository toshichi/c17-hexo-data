---
title: WSL 开启 SSH
date: 2020-10-08 12:17
tags: [WSL, ssh]
category: Windows
id: wsl-turn-on-ssh
cover: .images/WSL%20开启%20SSH/image-20201008131114568.png
---

## WSL1

``` bash
sudo dpkg-reconfigure openssh-server
sudo service ssh start
```

注意编辑密钥  
`~/.ssh/authorized_keys`  
文件权限 600，ssh 目录权限 755

## WSL2

### 1. 修改端口到高位

``` bash
vim /etc/ssh/sshd_config
```

### 2. 生成主机密钥

``` bash
cd /etc/ssh
ssh-keygen -A
```

### 3. 启动服务

``` bash
sudo service ssh start
```

### 4. 设置端口转发

``` bash
vim ~/port-forward.sh
```

``` bash
#!/bin/bash
IP=$(ifconfig eth0 | grep 'inet ' | awk '{print $2}')
netsh.exe interface portproxy delete v4tov4 listenport=23333
netsh.exe interface portproxy add    v4tov4 listenport=23333 connectaddress=$IP
```

``` bash
sudo chmod 700 ~/port-forward.sh
```

使用管理员权限 cmd 执行：

``` cmd
wsl -u root --exec /bin/bash /home/tojo/port-forward.sh
```

### 5. 设置开机自启

在 Windows 中打开计划任务 Task Scheduler，添加新任务，勾选使用最高权限执行。条件为系统启动和用户登录时。

![image-20201008122247581](.images/WSL%20开启%20SSH/image-20201008122247581.png)

添加两个操作，分别完成 ssh 启动和端口转发。

1. 执行 `cmd.exe`，参数为 `/c wsl -u root -- service ssh start`
2. 执行 `cmd.exe`，参数为 `/c wsl -u root --exec /bin/bash /home/tojo/port-forward.sh`

![image-20201008131114568](.images/WSL%20开启%20SSH/image-20201008131114568.png)

为了避免服务意外终止，可以增加第三个触发条件，每隔固定时间（图中为一小时）重复触发。

![image-20210422100712502](.images/WSL%20%E5%BC%80%E5%90%AF%20SSH/image-20210422100712502.png)

### 6. 设置防火墙

Windows 安全中心防火墙页面点击左下详细设置，在左侧入站规则中添加新的端口规则，允许外部访问 SSH 端口



参考：

<https://qiita.com/gengen16k/items/18262af0781fd32fc9cd>

<https://tombomemo.com/wsl2-install-settings>
