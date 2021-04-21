---
title: Docker volume 备份与恢复
date: 2020-07-29 19:16
tags: [Docker, volume, 备份]
category: Linux
id: docker-volume-backup
cover: false
---

https://jiajially.gitbooks.io/dockerguide/content/chapter_fastlearn/docker_run/--volumes-from.html

使用 --volumes-from 创建一个加载 dbdata 容器卷的容器，并从本地主机挂载当前到容器的 /backup 目录：

``` bash
sudo docker run --volumes-from aaa -v $(pwd):/backup alpine tar zcvf /backup/aaa.tar.gz /<path>
```

volumes-from 创建的容器其挂载的所有数据卷路径均与原容器相同，因此 `<path>` 改为原容器数据卷的挂载位置即可。

容器启动后，使用了 tar 命令来将 dbdata 卷备份为本地的 /backup/backup.tar。 如果要恢复数据到一个容器，首先创建一个带有数据卷的目标容器。（或者先创建空数据卷）

``` bash
sudo docker run -v volume_name:/volume_mount_path --name target alpine /bin/ash
```

然后创建另一个容器，挂载 dbdata2 的容器，并使用 untar 解压备份文件到挂载的容器卷中。

``` bash
sudo docker run --volumes-from target -v $(pwd):/backup alpine tar zxvf /backup/aaa.tar.gz -C /
```

其中 `-C /` 表示解压路径从根目录开始，从而确保路径和备份时完全对应。