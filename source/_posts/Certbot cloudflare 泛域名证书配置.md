---
title: Certbot cloudflare 泛域名证书配置
date: 2019-12-16 04:30
tags: [Certbot, cloudflare, 泛域名证书]
category: Services
id: certbot-cloudflare-wildcard
cover: false
---

## 1. 安装

``` bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt update
sudo apt install -y certbot python3-certbot-dns-cloudflare
```

## 2.  配置

>   Use of this plugin requires a configuration file containing Cloudflare API credentials, obtained from your Cloudflare account page.
>
>   ``` bash
>   vim /etc/letsencrypt/cloudflare.ini
>   ```
>
>   Example credentials file:
>
>   ``` ini
>   # Cloudflare API credentials used by Certbot
>   dns_cloudflare_email = cloudflare@example.com
>   dns_cloudflare_api_key = 0123456789abcdef0123456789abcdef01234567
>   ```
>   The path to this file can be provided interactively or using the --dns-cloudflare-credentials command-line argument. Certbot records the path to this file for use during renewal, but does not store the file’s contents.
>
>   ``` bash
>   sudo chmod 600 /etc/letsencrypt/cloudflare.ini
>   ```
>

## 3. 获取

``` bash
sudo certbot -a dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini -i nginx -d "*.coder17.com" -d coder17.com
```
注意不能完全信任其对 nginx 的修改

如果不需要自动修改 nginx 则：

``` bash
sudo certbot certonly -a dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini -d "home.coder17.com" -d "frph.coder17.com" -d "*.frph.coder17.com" -d "*.home.coder17.com"
```


## 4. 更新测试

``` bash
sudo certbot renew --dry-run
```

## 5. 部署自动更新

默认情况下会自动添加自动更新，每天两次。
使用 `sudo systemctl list-timers` 查看，配置文件位于 `/etc/systemctl/system/timers.target.wants/certbot.timer`

如果运行有问题，使用下面命令创建 crontab 任务，每两个月一次。


``` bash
sudo crontab -e

0 0 1 */2 * /usr/bin/certbot renew >> "/var/log/certbot_$(date +"\%Y-\%m-\%d").log" 2>&1

sudo service cron restart
```

## 6. 转换证书格式

默认申请的是 pem 格式证书，位于 `/etc/letsencrypt/live` 中，需要转换为 Windows 使用的 pfx 格式时，使用：

``` bash
openssl pkcs12 -export -out certificate.pfx -inkey privkey.pem -in cert.pem -certfile chain.pem -passout pass:
```

## 7. 复制

因为 live 目录中为软连接，复制时需要使用 `-L` 参数，如下：

``` bash
cp -Lr /etc/letsencrypt/live /mnt/hgfs/certs
```



Refer: https://certbot-dns-cloudflare.readthedocs.io/en/stable/