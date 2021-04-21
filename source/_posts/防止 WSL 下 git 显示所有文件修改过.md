---
title: 防止 WSL 下 git 显示所有文件修改过
date: 2018-06-19 18:33
tags: [WSL, git, autocrlf]
category: Windows
id: wsl-git-autocrlf
cover: false
---

如果常在 Windows 下使用 git，则修改 WSL 中 git 设置：

`git config --global core.autocrlf input`

如果常在 WSL 中使用，则修改 Windows 默认设置：

`git config --global core.autocrlf false`

