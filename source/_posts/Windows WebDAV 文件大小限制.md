---
title: Windows WebDAV 文件大小限制
date: 2020-10-05 01:53
tags: [Windows, WebDAV]
category: Windows
id: windows-dav-limit
cover: false
---

This sets the maximum you can download from the WebDAV to 4 GB at one time, where 4 GB is the maximum value supported by Windows OS.

``` ini
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WebClient\Parameters]
"FileSizeLimitInBytes"=dword:ffffffff
```



参考: <https://docs.druva.com/Knowledge_Base/inSync/Troubleshooting/WebDAV_download_fails_with_file_size_exceeds__the_limit_error>