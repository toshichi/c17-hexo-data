---
title: WinSCP 获取 sudo 权限
date: 2018-08-17 17:25
updated: 2018-11-26 03:18:06
tags: [WinSCP, sudo]
category: Windows
id: winscp-sudo
cover: .images/WinSCP%20获取%20sudo%20权限/8baf2e2e.png
---

1. 查看 sftp 路径

    ``` bash
    cat /etc/ssh/sshd_config|grep sftp
    Subsystem sftp /usr/lib/openssh/sftp-server
    ```

2. 编辑 sudo
    ``` bash
    sudo visudo

    # Allow members of group sudo to execute any command
    %sudo   ALL=(ALL:ALL) ALL
    tojo    ALL=NOPASSWD:  /usr/lib/openssh/sftp-server
    ```

3. 可选

    ![WinSCP 获取 sudo 权限_2018-11-26-03-18-06.png](.images/WinSCP%20获取%20sudo%20权限/8baf2e2e.png)