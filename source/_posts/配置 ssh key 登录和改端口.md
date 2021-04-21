---
title: 配置 ssh key 登录和改 sshd 端口
date: 2019-05-19 18:30
tags: [Linux, ssh, 端口]
category: Linux
id: config-sshd
cover: flase
---

## 保存 ssh-key

``` bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 500 .ssh/authorized_keys
```

## 禁用密码登录与改端口

``` bash
sudo vim /etc/ssh/sshd_config
```

``` conf
Port 22

# 启用密钥验证
RSAAuthentication yes # below 16.0
PubkeyAuthentication yes


# 指定公钥数据库文件
AuthorizedKeysFile %h/.ssh/authorized_keys # below 16.0
AuthorizedKeysFile .ssh/authorized_keys # 18.0

PasswordAuthentication no

```

``` bash
sudo service sshd restart
```
or

``` bash
sudo service ssh restart
```