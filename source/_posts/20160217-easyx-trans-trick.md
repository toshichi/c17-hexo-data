---
title: EasyX 框架实现透明图片显示的 trick
date: 2016-02-17 04:45
tags: [C, EasyX, trick, 图片]
category: [小技术, C]
id: 20160217-easyx-trans-trick
---
很多学校教授 C++ 图形编程时，为了规避 Windows 下 VC++ 较为复杂的绘图 API，都会（强制）要求学生使用 [EasyX](http://easyx.cn/) 这一绘图框架。该框架十分简陋地实现了初学者所需的图形功能。同时，此框架也存在大量不足，最为不便的就是不支持 png 格式图片，不支持透明背景绘图。  
<!-- more -->
鉴于此框架的 putimage 函数支持三元光栅操作码，我们可以利用掩码位图来变相实现透明背景绘图。  
参考了 http://code.qtuba.com/article-15636.html  
##1. 创建一个掩码位图  
掩码位图是一个单色位图，它的黑色部分就是位图显示时要保留的部分，白色部分就是要透明的部分。这里使用马里奥举例：  
原图：  
![](/blogimg/20160217-easyx-trans-trick/1.png)  
掩码图：  
![](/blogimg/20160217-easyx-trans-trick/2.png)  

##2.把掩码位图用SRCINVERT（XOR）方式叠加到原图  
白色XOR白色=黑色（白色的RGB都是255，1^1=0），黑色XOR任何颜色=原颜色（0^0=0，0^1=1）。操作完成后原图的透明区应被黑色填充。  
也可以直接用黑色填充原图。  

##3.把掩码位图用SRCAND（AND）方式叠加背景中  
白色and任何颜色=原颜色(1&1=1,1&0=0)，黑色and任何颜色=黑色（0&0=0，0&1=0）。  
![](/blogimg/20160217-easyx-trans-trick/3.png)  

##4.把叠加过的原图用SRCPAINT(or)方式叠加到背景中  
黑色or任何颜色=原颜色(0|1=1,0|0=0)。  
![](/blogimg/20160217-easyx-trans-trick/4.png)  
  
---
代码如下：
```cpp
#include <iostream>
#include <graphics.h>

using namespace std;

int main() {
	initgraph(800, 600);
	// Load background
	loadimage(NULL, _T("img\\background.jpg"));
	// Load mario
	IMAGE mariox, mario;
	loadimage(&mariox, _T("img\\mariox.bmp"));
	loadimage(&mario, _T("img\\mario.bmp"));
	// Trick to display transparent image
	SetWorkingImage(&mario);
	putimage(0, 0, &mariox, SRCINVERT);
	SetWorkingImage(NULL);
	putimage(400, 465, &mariox, SRCAND);
	putimage(400, 465, &mario, SRCPAINT);

	getchar();
	closegraph();
	return 0;
}
```

---

<p align = right>
by Sykie Chen
2016.2.17
</p>