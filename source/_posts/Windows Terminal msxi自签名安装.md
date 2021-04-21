---
title: 不装 VS Windows Terminal 编译 msxi 自签名安装
date: 2019-06-16
tags: [Windows Terminal, DevOps, msxi, 自签名, 编译, SignTools]
category: Windows
id: msxi-sign-install
cover: .images/Windows%20Terminal%20msxi自签名安装/1560680665789.png
---

Windows Terminal 一直没有发布可以直接安装的二进制文件，想自行编译的时候，看到系统需求中包含体积巨大的 Visual Studio 和 Windows SDK，脑袋都大了。直接下载其他人编译好的安装包又不放心，那么就想个办法避免在本地环境编译吧。

## 1. 编译结果获取

首先想到 Azure DevOps，这个可以简单理解成微软提供的在线 CI 平台，写好编译文件就可以调用微软的自带所有编译环境的镜像直接在线编译，并生成二进制下载。这个服务可以使用 edu 教育账号免费使用，有 edu 邮箱的都可以用。我曾经使用这个编译过其他人久不更新的 MFC 项目。自己写一个 ，或者修改微软生成的 `azure-pipelines.yml` 即可。

![1560678181063](.images/Windows%20Terminal%20msxi自签名安装/1560678181063.png)

那么就从 GitHub 上把微软的代码拿过来，再写个 pipeline 直接编译吧。这时注意到，GitHub 上的项目中，居然已经包含了写好的 pipeline。

![1560678325392](.images/Windows%20Terminal%20msxi自签名安装/1560678325392.png)

想了想也是自然，微软写的东西当然自己也会用 Azure DevOps 啊。

接下来注意到，在 GitHub 仓库的 Readme 中，已经有 Azure Pipelines 的编译结果图标了。

![1560678474529](.images/Windows%20Terminal%20msxi自签名安装/1560678474529.png)

单击图标，打开软的 DevOps 仓库，可见每次 push 代码都是会自动编译的。进一步分析发现，只有合并到 master 分支时会编译出二进制文件。

![1560678578167](.images/Windows%20Terminal%20msxi自签名安装/1560678578167.png)

那么我们选择其中一个 master 分支的 CI job：

![1560678636549](.images/Windows%20Terminal%20msxi自签名安装/1560678636549.png)

可以看到，右上角有 Artifacts 按钮，说明这个 CI 是会上传编译出来的二进制文件到服务器的。不清楚这三个有什么区别，我起初以为分别对应 x64、x86 和 arm64 的编译结果，但我下载第一个压缩包中，是包含了三个平台的编译结果的。压缩包很大，150多M，内容如下：

![1560678772276](.images/Windows%20Terminal%20msxi自签名安装/1560678772276.png)

其中的 `CascadiaPackage_0.0.1.0_x64.msix` 就是我们要的二进制安装包。

## 2. 安装尝试

首先把系统调成开发者模式。

![1560678844942](.images/Windows%20Terminal%20msxi自签名安装/1560678844942.png)

然后双击 msix 文件直接安装，发现安装失败，提示安装包没有签名。

![1560679034249](.images/Windows%20Terminal%20msxi自签名安装/1560679034249.png)

一番搜索之后，发现如果使用 VS 在本机直接部署，VS 会自动帮你签名。如果使用 VS 命令行工具直接编译出来的结果，是没有签名的。

在 GitHub 仓库的一个 [issue](https://github.com/microsoft/Terminal/issues/489#issuecomment-496170540) 中有人提到，需要用 `SignTool.exe` 来为这个安装包签名。

## 3. 证书生成

签名首先需要一个证书。在这里我们直接自签发一个证书并添加信任就行了。参考刚才的 issue 中提到的脚本，打开管理员权限的 Power Shell ，并 cd 到 msix 安装包所在目录中，执行如下命令：

``` powershell
New-SelfSignedCertificate -Type Custom -Subject "CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US" -KeyUsage DigitalSignature -FriendlyName "WindowsTerminal" -CertStoreLocation "Cert:\LocalMachine\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")
```

此时会显示一个证书指纹，复制其中指纹并替换掉下面命令中的 `C5C9D98CE9A23FB72C20B4D039876F3D93C3E1FF`，同时修改命令中的密码。

``` powershell
$password = ConvertTo-SecureString -String "随便设置一个密码" -Force -AsPlainText
Export-PfxCertificate -cert "Cert:\LocalMachine\My\C5C9D98CE9A23FB72C20B4D039876F3D93C3E1FF" -FilePath WindowsTerminal.pfx -Password $password
Remove-Item -Path "Cert:\LocalMachine\My\C5C9D98CE9A23FB72C20B4D039876F3D93C3E1FF"
```

此时当前目录会生成一个 `WindowsTerminal.pfx` 证书。双击之，安装到计算机存储的受信任人（Trusted People）目录中，中间会要你输入刚才脚本里设置的密码。

![1560679602449](.images/Windows%20Terminal%20msxi自签名安装/1560679602449.png)

好了，证书搞定了。

## 4. 提取安装签名工具

下面使用  `SignTool.exe` 工具进行签名。这个工具是 [Windows 10 SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk) 中的一个工具。去微软网站查看发现，这货体积巨大，包含了许多开发 Windows 所需的工具包。但我们并不需要其他的部分，所以这里投机取巧一下，只安装所需的部分。

首先要下载 ISO 格式的安装镜像，不要直接下 Installer。大概 800M 左右，半夜直连下载速度飞快，白天就不行了，视情况使用更加科学的上网方式。

![1560679726239](.images/Windows%20Terminal%20msxi自签名安装/1560679726239.png)

下好之后，使用 Windows 自带的 Mount 功能映射为虚拟光驱。打开 `Installers` 目录，找到 `Windows App Certification Kit x64-x86_en-us.msi` 这个包，双击安装。

![1560679991475](.images/Windows%20Terminal%20msxi自签名安装/1560679991475.png)

这个工具包就包含了我们需要的 `SignTools.exe` ，其他的部分不需要，可以删掉这个镜像了。在 `C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe` 路径可以找到我们需要的工具。

![1560680492261](.images/Windows%20Terminal%20msxi自签名安装/1560680492261.png)

## 5. 签名安装

在 msix 和证书文件所在目录打开 cmd，执行以下命令完成签名：

``` bat
"C:\Program Files (x86)\Windows Kits\10\App Certification Kit\signtool.exe" sign /fd SHA256 /a  /f WindowsTerminal.pfx /p 你的密码 CascadiaPackage_0.0.1.0_x64.msix
```

签好后再双击 msix 包，就可以顺利安装了。

![1560680665789](.images/Windows%20Terminal%20msxi自签名安装/1560680665789.png)

Enjoy！

![1560681595443](.images/Windows%20Terminal%20msxi自签名安装/1560681595443.png)