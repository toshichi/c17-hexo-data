---
title: 新建 Windows 服务
date: 2018-11-08 16:07
tags: [Windows, 服务, srvany]
category: Windows
id: create-windows-service
cover: false
---

1. 下载 [Windows NT Resource Kit](https://www.microsoft.com/en-us/download/details.aspx?id=17657)

2. 添加指向 `srvany.exe` 的服务

    ``` cmd
    sc create <name> binpath= "C:\Program Files (x86)\Windows Resource Kits\Tools\srvany.exe" start= auto displayname= "<Display Name>"
    ```

3. 修改注册表

    定位到

    ``` reg
    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\<name>
    ```

    添加子键

    ``` reg
    Key Name: Parameters
    Class : <leave blank>
    ```

    在子键下新建字符串值，指向真正要启动的程序

    ``` reg
    Value Name: Application
    Data Type : REG_SZ
    String : <path>\<application.ext>
    ```

4. 进 services.msc 看看，启动

参考：<https://support.microsoft.com/en-us/help/137890/how-to-create-a-user-defined-service>
