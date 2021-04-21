---
title: WSL 同步主机 ssh key
date: 2019-05-19 18:39
tags: [WSL, ssh]
category: Windows
id: wsl-sync-ssh-keys
cover: false
---

``` bash
vim ~/.bashrc
vim ~/.zshrc

mv -f ~/.ssh/known_hosts ~/.ssh/known_hosts.bak
chmod -R 0755 ~/.ssh
cp -r /mnt/c/Users/sykie/.ssh/* ~/.ssh
chmod 0600 ~/.ssh/*
chmod 0755 ~/.ssh
mv -f ~/.ssh/known_hosts.bak ~/.ssh/known_hosts
```