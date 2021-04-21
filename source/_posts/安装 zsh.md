---
title: 安装 zsh
date: 2019-05-19 04:16
updated: 2020-11-30 23:51
tags: [Linux, zsh, oh my zsh]
category: Linux
id: install-zsh
cover: false
---

## 1. zsh

``` shell
sudo apt install zsh
```

## 2. [oh my zsh](https://github.com/robbyrussell/oh-my-zsh) and theme

``` shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo apt install fonts-powerline
vim ~/.zshrc
```

``` shell
ZSH_THEME="agnoster" # (this is one of the fancy ones)
# see https://github.com/robbyrussell/oh-my-zsh/wiki/Themes#agnoster
```

## 3. WSL: [ColorTool](https://github.com/Microsoft/Terminal/tree/master/src/tools/ColorTool)

## 4. `Ctrl + Backspace` and `Ctrl + Delete`

``` shell
echo "bindkey '^H' backward-kill-word" >> ~/.zshrc
echo "bindkey '^[[3;5~' kill-word" >> ~/.zshrc
```

[Why don't Ctrl+Backspace and Ctrl+Delete work? · Issue #7609 · robbyrussell/oh-my-zsh · GitHub](https://github.com/robbyrussell/oh-my-zsh/issues/7609)

## 6. ll
``` shell
echo "alias ll='ls -alhF'" >> ~/.bash_aliases
echo "source \$HOME/.bash_aliases" >> ~/.zshrc
```

## 5. Plugins

## 5.1 [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md)

``` shell
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
chmod -R 755 ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

## 5.2 [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)

``` shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
chmod -R 755 ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

## 5.3 [zsh-z](https://github.com/agkozak/zsh-z#installation)

``` shell
git clone https://github.com/agkozak/zsh-z ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
chmod -R 755 ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-z
```

## 5.x Enable

``` shell
vim ~/.zshrc
```

```
plugins=(
	git
	extract
	z
	zsh-syntax-highlighting
	zsh-autosuggestions
)
```

## 6. WSL: fix `\_z\_precmd:1: nice(5) failed: operation not permitted`

> By default, `zsh` tries to run background jobs at a lower priority, which Windows won't let it do. A good workaround is to put
>
> ```
> case $(uname -a) in
> *Microsoft*) unsetopt BG_NICE ;;
> esac
> ```
>
> in your `.zshrc` file. That alters `zsh`'s default behavior and fixes the problem entirely, in my experience.

[_z_precmd:1: nice(5) failed: operation not permitted · Issue #230 · rupa/z · GitHub](https://github.com/rupa/z/issues/230)

## 7. Hide local username and host name

``` shell
echo "DEFAULT_USER=\"\$USER\"" >> ~/.zshrc
```

## 8. Change  host name text color

``` bash
vim ~/.oh-my-zsh/themes/agnoster.zsh-theme
```

``` bash
@@ -89,7 +89,7 @@ prompt_end() {
 # Context: user@hostname (who am I and where am I)
 prompt_context() {
   if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
-    prompt_segment black default "%(!.%{%F{yellow}%}.)%n@%m"
+    prompt_segment cyan white "%(!.%{%F{yellow}%}.)%n@%m"
   fi
 }
```

