---
title: Portainer 启动/升级
date: 2020-03-26 17:41
tags: [Portainer]
category: Services
id: protainer-launch-update
cover: false
---

## Launch

``` bash
docker volume create portainer_data
docker run -d -p 127.0.0.1:9000:9000 -p 8000:8000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --restart unless-stopped --name portainer portainer/portainer
```

From <https://portainer.io/install.html> 

## Update

- 在 Web 界面执行 Duplicate/Edit

- 直接确认后，会自动拉取新镜像并停止旧 Container，但不能自动拉起新 Container

- SSH 登录，手动删除旧 Container，再使用上述第二条命令重新拉起即可

  ``` bash
  sudo docker rm portainer
  ```

  

