---
title: Windows RDP 添加证书
date: 2019-05-26 13:13
tags: [Windows, RDP, 证书]
category: Windows
id: windows-rdp-cert
cover: .images/Windows%20RDP%20添加证书/1558647325871.png
---

使用远程桌面时，默认使用自签发的证书，会导致连接时弹出 SSL 证书警告。

![1558647325871](.images/Windows%20RDP%20添加证书/1558647325871.png)

勾上不提醒可以消除警告，但会导致 SSL 连接不安全。因此导入第三方签发的证书解决问题。

下面以 Let's Encrypt 的证书为例：

## 1. 证书格式

证书必须为 pfx 格式，转换 pem 时使用：

``` bash
openssl pkcs12 -export -out certificate.pfx -inkey privkey.pem -in cert.pem -certfile chain.pem -passout pass:
```

## 2 手动添加并关联证书

[英文参考](https://superuser.com/questions/1093159/how-to-provide-a-verified-server-certificate-for-remote-desktop-rdp-connection)  [CSDN 参考](https://blog.csdn.net/a549569635/article/details/48831105)

### 2.1 运行 mmc，添加证书管理单元

> 在 **文件** 中选择 **添加/删除管理单元** 。
>
> ![管理控制台](.images/Windows%20RDP%20添加证书/20150930203909755)
>
> 在左侧选中 **证书** 后点击 **添加** 。
>
> ![添加或删除单元](.images/Windows%20RDP%20添加证书/20150930204204227)
>
> 在弹出的对话框中选择 **计算机账户**，点击 **下一步** 。
>
> ![1558648079123](.images/Windows%20RDP%20添加证书/1558648079123.png)
>
> 之后选择 **本地计算机**（保持默认） 然后点击 **完成** ，再然后点击 **确定** 。
>

### 2.2 把证书添加到 Local Computer 下的 Personal 中

> 在 **证书-个人** 上点击 **右键** ，选择 **所有任务-导入** 。
>
> ![右键](.images/Windows%20RDP%20添加证书/20150930205922703)
>
> 按照向导点击 **下一步** ,之后选择你的 **证书文件** （**p12**格式的证书文件选择时需要更改文件类型才可以找到），之后需要输入之前设置的密码，**证书存储** 选择 **根据证书类型，自动选择证书存储** ，然后点击下一步即可。
>

### 2.3 添加权限

> 首先在已经导入的证书上点击 **右键** ，选择 **所有任务-管理私钥** 。
>
> 之后添加 **NETWORK SERVICE** 用户。
>
> 至少要将 **读取** 权限分配给 **NETWORK SERVICE** ，然后确定。
>

### 2.4 分配给远程桌面

> 展开路径 **HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp** ，然后添加如下项：
>
> 名称: SSLCertificateSHA1Hash 
> 类型: REG_BINARY
>
> ![新建项](.images/Windows%20RDP%20添加证书/20150930220406678)
>
> 之后回到之前的证书管理，双击打开已经导入的证书，在 **详细信息** 中选择 **指纹** ，并记录下方的值。
>
> ![证书指纹](.images/Windows%20RDP%20添加证书/20150930221224563)
>
> 最后将记录的值填入之前新建注册表项的 **数据** 位置。
>
> ![填入指纹](.images/Windows%20RDP%20添加证书/20150930221424388)

## 3. 使用 Powershell 自动添加/替换证书

``` powershell
$certPath = "C:\certs\live\certificate.pfx"

# get TSGeneralSetting
$TSGeneralSetting = gwmi -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'"

# remove old cert
$oldThumbprint = $TSGeneralSetting.SSLCertificateSHA1Hash
Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -like $oldThumbprint} | Remove-Item

# import new cert
"" | certutil -f -importPFX $certPath
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import($certPath, "", [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]"PersistKeySet")

# set permission
$WinhttpPath = "C:\Program Files (x86)\Windows Resource Kits\Tools"
&"$WinhttpPath\winhttpcertcfg.exe" -g -c LOCAL_MACHINE\MY -s $cert.Subject.split("=")[1] -a "NETWORK SERVICE"

# set to rdp
swmi -path $TSGeneralSetting.__path -argument @{SSLCertificateSHA1Hash=$cert.Thumbprint}
```

使用计划任务运行上述脚本即可定期自动更新证书，注意需要管理员权限。

### 3.1 坑：添加证书使用 Import-PfxCertificate

注意，添加证书时，不能使用[`Import-PfxCertificate`](https://docs.microsoft.com/en-us/powershell/module/pkiclient/import-pfxcertificate?view=win10-ps#feedback)，此函数有 [bug](https://github.com/MicrosoftDocs/windows-powershell-docs/issues/295)，添加的证书无法查看私钥，非常坑。

以下代码返回空值，因此不能修改权限：

``` powershell
$item = (Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -like $Thumbprint})
$item.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
```



### 3.2 坑：添加证书使用
`System.Security.Cryptography.X509Certificates.X509Store`

添加代码如下：

``` powershell
# import new cert
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import("C:\certs\certificate.pfx", "password", [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]"PersistKeySet")
$store = New-object System.Security.Cryptography.X509Certificates.X509Store -argumentlist "MY", LocalMachine
# $store = Get-Item cert:\LocalMachine\My
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]"ReadWrite")
$store.Add($cert)
$store.Close()
```

使用上面代码中方法安装的证书，虽然可以获取到私钥，但提示文件不存在。会出现无法使用以下代码操作修改权限的情况：

``` powershell
# set permission
$item = (Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -like $Thumbprint})
$fullPath = Join-Path $env:ProgramData\Microsoft\Crypto\RSA\MachineKeys $item.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
$acl = Get-Acl -Path $fullPath
$permission = "NT AUTHORITY\NETWORK SERVICE","Read","Allow"
$accessRule = New-object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)
Set-Acl $fullPath $acl
```

错误信息如下：

![1558717520224](.images/Windows%20RDP%20添加证书/1558717520224.png)

原因不明，只有通过 mmc 图形界面导入的证书无此问题。

因此尝试使用 [`WinHttpCertCFG`](https://www.microsoft.com/en-us/download/details.aspx?id=19801) 进行权限修改。

``` powershell
# set permission
$WinhttpPath = "C:\Program Files (x86)\Windows Resource Kits\Tools"
&"$WinhttpPath\winhttpcertcfg.exe" -g -c LOCAL_MACHINE\MY -s $cert.Subject.split("=")[1] -a "NETWORK SERVICE"
```

但即使权限修改成功，此时导入的证书仍无法设置为 `SSLCertificateSHA1Hash`，报错如下：

``` powershell
swmi : Invalid parameter
At line:1 char:1
+ swmi -path $TSGeneralSetting.__path -argument @{SSLCertificateSHA1Has ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Set-WmiInstance], ManagementException
    + FullyQualifiedErrorId : SetWMIManagementException,Microsoft.PowerShell.Commands.SetWmiInstance
```

![1558720712709](.images/Windows%20RDP%20添加证书/1558720712709.png)



mmc 导入的证书同样无问题。因此尝试 [`certutil`](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/certutil) 导入证书。

``` powershell
"" | certutil -f -importPFX $certPath
```

前方空引号用于传递空密码。