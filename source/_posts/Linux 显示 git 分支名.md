---
title: Linux 显示 git 分支名
date: 2018-10-31 11:55
updated: 2019-05-22 04:16
tags: [Linux, git]
category: Linux
id: linux-git-branch-name
cover: false
---

1. Download [this](https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh)

2. Copy to `~/.git-prompt.sh`, or wget it.

3. `.bashrc`

``` bash

source ~/.git-prompt.sh

export PS1='\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(__git_ps1)\[\033[00m\]\$ '
```