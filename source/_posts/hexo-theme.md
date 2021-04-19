---
title: Hexo Landscape 主题修改优化
date: 2015-05-23 23:18:15
tags: [Hexo, Landscape, 主题, 博客, 前端]
category: [小技术, HTML]
id: hexo-theme
---
&emsp;&emsp;这几天用 Hexo 搭了个静态博客。觉得默认的 Landscape 主题挺好看，但有些地方很奇怪。别人改好的 Landscape-plus 和 Landscape-f 改动太大，用着不爽，就决定自己从头造个轮子修改一下。


&emsp;&emsp;基于 [Landscape](https://github.com/hexojs/hexo-theme-landscape)，修改添加了部分功能。部分参考了 [Landscape-F](https://github.com/howiefh/hexo-theme-landscape-f) 和  [Landscape-plus](https://github.com/xiangming/landscape-plus)。
&emsp;&emsp;文章参考来源以链接形式放在各节小标题上。有基于原文完善或修改的地方不再另行注明。

## 1. [Google jQuery 库的优化](http://kuangqi.me/tricks/hexo-optimizations-for-mainland-china/) ##

`layout\_partial\after-footer.ejs` 17行

```xml
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js"></script>
```
<!-- more -->

替换为如下代码：

```xml
<script src="http://lib.sinaapp.com/js/jquery/2.0.3/jquery-2.0.3.min.js"></script>
<script type="text/javascript">
//<![CDATA[
if (typeof jQuery == 'undefined') {
  document.write(unescape("%3Cscript src='/js/jquery-2.0.3.min.js' type='text/javascript'%3E%3C/script%3E"));
}
// ]]>
</script>
```
这里不但将 Google 的 jQuery 替换成了 SAE 的，随后还进行了一个判断，如果获取新浪的 jQuery 失败，则使用本网站自己的 jQuery。为了让这段代码有效，我们要去 jQuery 官方下载合适版本的 jQuery 并将其放到 `source\js\ ` 目录下，命名为 `jquery-2.0.3.min.js`。
还有一点需要特别注意，那就是 jQuery 这个文件在 hexo 生成博客时会被解析，因此一定要将 jQuery 文件开头处的 `//@ sourceMappingURL=jquery-2.0.3.min.map` 这一行代码删去，否则会导致博客无法生成。

## 2. [跨平台字体优化](http://kuangqi.me/tricks/hexo-optimizations-for-mainland-china/) ##

为了能在各个平台上都显示令人满意的字体，我们要修改 CSS 文件中的字体设置，列出多个备选的字体，操作系统会依次尝试，使用系统中已安装的字体。我们要修改的是`source\css\_variables.styl`这一文件，将其中第22行
```javascript
font-sans = "Helvetica Neue", Helvetica, Arial, sans-serif
```
改成如下内容：
```javascript
font-sans = Tahoma, "Helvetica Neue", Helvetica, "Hiragino Sans GB", "Microsoft YaHei Light", "Microsoft YaHei", "Source Han Sans CN", "WenQuanYi Micro Hei", sans-serif
```
其中 Helvetica、Verdana 是英文字体，前者一般存在于苹果电脑和移动设备上，后者一般存在于 Windows 系统中。冬青黑体（Hiragino Sans GB）、思源黑体（Source Han Sans CN）、文泉驿米黑（WenQuanYi Micro Hei）是中文字体，冬青黑体从 OS X 10.6 开始集成在苹果系统中，文泉驿米黑在Linux的各大发行版中均较为常见，而思源黑体是近期 Google 和 Adobe 合作推出的一款开源字体，很多电脑上也安装了这一字体。这样一来，在绝大部分操作系统中就可以显示美观的字体了。

##3. [代码块等宽字体优化](https://www.snip2code.com/Snippet/466525/replace-the-google-link%28css-js%29-to-baidu) ##

`layout\_partial\head.ejs` 第31行
```xml
<link href="http://fonts.googleapis.com/css?family=Source+Code+Pro" rel="stylesheet" type="text/css">
```
改为
```xml
<link href="http://fonts.useso.com/css?family=Source+Code+Pro" rel="stylesheet" type="text/css">
```

##4. 修改添加分享链接 ##
###4.1 [百度分享框](http://share.baidu.com/code)###

在百度分享获取代码后，代码可分为两部分。
在`layout\_partial\article.ejs`中第26行插入第一段代码并添加判断条件，若当前页为文章展开页则显示百度分享框，若是缩略则采用原生分享链接，避免百度分享框获取的 URL 错误：
```xml
<% if ((page.layout == 'post'|| page.layout == 'page')){ %>
  <div class="bdsharebuttonbox"><a href="<%- post.permalink %>">分享到：</a><a href="#" class="bds_tsina" data-cmd="tsina" title="分享到新浪微博">新浪微博</a><a href="#" class="bds_renren" data-cmd="renren" title="分享到人人网">人人网</a><a href="#" class="bds_qzone" data-cmd="qzone" title="分享到QQ空间">QQ空间</a><a href="#" class="bds_weixin" data-cmd="weixin" title="分享到微信">微信</a><a href="#" class="bds_fbook" data-cmd="fbook" title="分享到Facebook">Facebook</a><a href="#" class="bds_twi" data-cmd="twi" title="分享到Twitter">Twitter</a><a href="#" class="bds_more" data-cmd="more">其他平台</a></div>
<% } else { %>
  <a data-url="<%- post.permalink %>" data-id="<%= post._id %>" class="article-share-link">分享</a>
<% } %>
```

在`layout\_partial\after-footer.ejs`末尾添加第二部分代码
```xml
<!-- Baidu Share Start --->
<script>window._bd_share_config={"common":{"bdSnsKey":{"tsina":"1714312189"},"bdWbuid":3904642734,"bdText":"","bdMini":"2","bdMiniList":["douban","kaixin001","tieba","tsohu","sqq","youdao","qingbiji","mail","linkedin","mshare","copy","print"],"bdPic":"http://www.devchen.com/SharePic.png","bdStyle":"1","bdSize":"24"},"share":{"bdSize":16}};with(document)0[(getElementsByTagName('head')[0]||body).appendChild(createElement('script')).src='http://bdimg.share.baidu.com/static/api/js/share.js?v=89860593.js?cdnversion='+~(-new Date()/36e5)];</script>
<!--- Baidu Share End --->
```
其中`1714312189`为我申请的微博开放平台的 App Key，申请后分享可以显示尾巴。`3904642734`是我的微博 ID，作用是在文本框里自动艾特我的微博。
注意保存时将编码改为 UTF-8，否则会乱码。

### 4.2 [原生分享的修改](http://blanboom.org/hack-hexo-theme-landscape.html) ###
在 `source\js\script.js` 中，57行 `'<div class="article-share-links">'`,，下面的四个链接就是 Facebook 等社交网站的分享链接。将其替换或添加如下代码，即可实现分享到国内社交网站：
```xml
'<a href="http://service.weibo.com/share/share.php?appkey=1714312189&pic=http%3A%2F%2Fwww.devchen.com%2FSharePic.png&ralateUid=3904642734&searchPic=true&url=' + encodedUrl + '" class="article-share-sina" target="_blank" title="微博"></a>',
'<a href="http://share.renren.com/share/buttonshare.do?link=' + encodedUrl + '" class="article-share-renren" target="_blank" title="人人"></a>',
'<a href="http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=' + encodedUrl + '" class="article-share-qq" target="_blank" title="QQ空间"></a>',
'<a href="http://qr.liantu.com/api.php?text=' + encodedUrl + '" class="article-share-wechat" target="_blank" title="微信"></a>',
```
注意，微博中`“3904642734”`是我的微博ID，作用是在文本框里自动艾特我的微博。
微信分享中 `http://qr.liantu.com/api.php?text=` 这个地址是 [联图网](http://www.liantu.com/pingtai/) 提供的二维码 API ，用微信扫描后分享。

同时，还需要替换图标。本主题使用 Font Awesome 来显示图标，但内置的 Font Awesome 版本较旧，无法显示 QQ、腾讯微博等图标，所以，需要下载最新版 [Font Awesome](http://fortawesome.github.io/Font-Awesome/)，替换掉 `source\css\fonts` 中相关文件，并在` source\css\_variables.styl` 中27行的 `font-icon-version` 修改为最新的 Font Awesome 版本号。

然后，在 `source\css\_partial\article.styl` 中，找到四段以 `.article-share-***` 开头的代码（273行起），添加如下内容：

```javascript
.article-share-sina
  @extend $article-share-link
  &:before
    content: "\f18a"
  &:hover
    background: color-sina
    text-shadow: 0 1px darken(color-sina, 20%)

.article-share-qq
  @extend $article-share-link
  &:before
    content: "\f1d6"
  &:hover
    background: color-qq
    text-shadow: 0 1px darken(color-qq, 20%)

.article-share-renren
  @extend $article-share-link
  &:before
    content: "\f18b"
  &:hover
    background: color-renren
    text-shadow: 0 1px darken(color-renren, 20%)

.article-share-wechat
  @extend $article-share-link
  &:before
    content: "\f1d7"
  &:hover
    background: color-wechat
    text-shadow: 0 1px darken(color-wechat, 20%)
```
最后，找到 `source\css\_variables.styl` 中 `Colors` 部分（16行），最后四行分别为社交网站图标的背景色，可根据这些网站的主题色修改。
```javascript
color-sina = #ff8140
color-qq = #ffcc33
color-renren = #227dc5
color-wechat = #44b549
```

##5. [安装 RSS 和 sitemap 插件](http://starsky.gitcafe.io/2015/05/05/Hexo%E4%B8%BB%E9%A2%98%E9%85%8D%E7%BD%AE%E4%B8%8E%E4%BC%98%E5%8C%96%EF%BC%88%E4%B8%80%EF%BC%89/)##

```bash
$ npm install hexo-generator-feed --save
$ npm install hexo-generator-sitemap --save
```
修改 `hexo\_config.yml` 站点配置，添加：
```json
# Extensions
Plugins:
  hexo-generator-feed
  hexo-generator-sitemap

#Feed Atom
feed:
  type: atom
  path: atom.xml
  limit: 20

#sitemap
sitemap:
  path: sitemap.xml
```
然后注意再修改`_config.yml`主题配置：
`menu:`里添加网站地图:` /sitemap.xml`
下面也添加`rss: /atom.xml`（如果有就不用添加了）。

部署后就能看到“首页”那一栏多了个“网站地图”，点击后有内容且第一行为
`This XML file does not appear to have any style information associated with it. The document tree is shown below.`
就说明成功了。
RSS 也是一样。

##6. 卡片增加阴影 ##
`source/css/_partial/header.styl`第5行添加：
```javascript
-webkit-box-shadow: 2px 4px 5px rgba(3,3,3,0.2)
box-shadow: 2px 4px 5px rgba(3,3,3,0.2)
```
##7. 坑：试图将侧栏放到左面 ##
在`config.yml`中可以配置 Sidebar 为 left。但如此配置后页面在移动端（窄屏）下会错位，文章卡片跑到屏幕外面了。经文件比对后发现修改了该选项仅使`css\style.css`中190行处添加了 right 从右向左的布局。该布局虽使文章列与侧栏列交换，但窄屏时因为右对齐所以左边界会超出屏幕。尝试将 index.html 中两栏位置互换，错位问题解决，但窄屏下侧栏在文章上方。

遂弃坑。

##8. 补救：将文章卡片页面宽度缩窄 ##
之所以想将侧栏放到左面是因为屏宽超过1024时若文章换行较多中部会很空。于是可以限制文章页面宽度。
在`source\css\_variables.styl`中将47行`main-column`的值由默认的9改为8，侧栏宽度由3改为2.5。

##9. [代码块修改](http://blog.sunnyxx.com/2014/03/07/hexo_customize/) ##
`source\css\_partial\highlight.styl` 17行改为
```javascript
margin: auto
```
使代码块不再左右撑开
22行添加
```javascript
border-radius: 8px
```
圆角。

##10. 页尾版权信息修改 ##
原生的好丑啊！
`layout\_partial\footer.ejs`
添加一个表格，实现分散对齐。添加了网站地图等链接。
```xml
<div class="outer">
    <div id="footer-info" class="inner" style="text-align:center;">
	  <table width="100%" border="0">
        <tr>
          <td style="text-align:left">
            Copyright &copy; 2014-<%= date(new Date(), 'YYYY') %> <%= config.author || config.title %> &nbsp; &nbsp;
            Powered by <a href="http://hexo.io/" target="_blank">Hexo</a><br>
	        Theme <a href="https://github.com/sykiechen/hexo-theme-hic17" target="_blank">HiC17</a> by Sykie Chen &nbsp; &nbsp;
	        Hosted on <a href="http://gitcafe.com/" target="_blank">Git Cafe</a>
		  </td>
		  <td style="text-align:right">
		    <div style="font-family: FontAwesome;font-size: 20px;">
		    <a href="http://weibo.com/3904642734" title="微博" target="_blank">&#61834;</a>&nbsp;
			<a href="http://www.renren.com/287137027" title="人人" target="_blank">&#61835;</a>&nbsp;
			<a href="http://user.qzone.qq.com/525969441" title="QQ空间" target="_blank">&#61910;</a>&nbsp;
			<a href="https://www.facebook.com/sykiechencixi" title="Facebook" target="_blank">&#62000;</a>&nbsp;
			<a href="https://twitter.com/HKEY_C17" title="twitter" target="_blank">&#61593;</a>&nbsp;
			<a href="http://www.linkedin.com/in/sykiechen" title="LinkedIn" target="_blank">&#61665;</a>&nbsp;
			<a href="https://github.com/sykiechen" title="GitHub" target="_blank">&#61595;</a>&nbsp;
			<a href="https://plus.google.com/118157846818083514683" title="Google+" target="_blank">&#61653;</a>
			</div><br>
		    <a href="/sitemap.xml">网站地图</a>&nbsp; &nbsp;
			<a href="/atom.xml">订阅本站</a>&nbsp; &nbsp;
			<a href="mailto:i@devchen.com" target="_blank">联系博主</a>&nbsp; &nbsp;
			ICP 备案你妹
		  </td>
        </tr>
      </table>
    </div>
</div>
```

此处使用了 Font Awesome 字体中的图标。官网介绍的使用方法是包含一个 css 文件进去。然而 Landscape 主题已经使用过该字体，所以该 css 文件的内容应已包含在 style.css 内。故将 html a 标签的 font 指定为该字体，内容处填写~~&#`UTF编码的十进制值`; 可用计算器将官网给出的十六进制 UTF 区位码转换为十进制。~~ &#x`UTF十六进制值`;。

##11. [多说评论框](http://howiefh.github.io/2014/04/20/hexo-optimize-and-my-theme-landscape-f/) ##

在`layout\_partial\article.ejs`中将中部 dis 评论按钮代码替换为：
```javascript
<% if (post.comments){ %>
  <a href="<%- post.permalink %>#ds-thread" class="ds-thread-count article-comment-link" data-thread-key="<%- post.path%>">评论</a>
<% } %>
```
底部评论框替换为：
```javascript
<% if (!index && post.comments){ %>
<section id="comments">
<!-- 多说评论框 start -->
	<div id="ds-thread" class="ds-thread" data-thread-key="<%= post.path%>" data-title="<%= post.title %>" data-url="<%= post.permalink %>"></div>
<!-- 多说评论框 end -->
</section>
<% } %>
```
`layout\_partial\after-footer.ejs`中 dis 评论框 js 替换为从多说获得的代码：
```xml
<!-- 多说公共JS代码 start (一个网页只需插入一次) -->
<script type="text/javascript">
var duoshuoQuery = {short_name:"hkeyc17"};
	(function() {
		var ds = document.createElement('script');
		ds.type = 'text/javascript';ds.async = true;
		ds.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + '//static.duoshuo.com/embed.js';
		ds.charset = 'UTF-8';
		(document.getElementsByTagName('head')[0] 
		 || document.getElementsByTagName('body')[0]).appendChild(ds);
	})();
	</script>
<!-- 多说公共JS代码 end -->
```

##12. [侧栏微博框](http://kuangqi.me/tricks/add-weibo-show-in-hexo/) ##

登录[新浪微博开放平台](http://app.weibo.com/tool/weiboshow)来获取微博秀的代码。然后新建`themes/landscape/layout/_widget/weibo.ejs`这个文件，将刚刚获取到的代码添加到这个文件中。最后编辑`themes/landscape/_config.yml`，在`widgets:`标签后面的适当位置添加`- weibo`。这样微博秀应该就可以显示在你的博客上了。
可以在该文件前后加入条件
`<% if (is_home()){ %>`
`<% } %>`
来限制该挂件仅在主页显示。

上述方法添加的微博秀没有标题文字，也不像landscape的其他widget那样具有圆角矩形、带内阴影的边框，所以获取微博代码时就要进行一些设置，为了将微博秀“嵌入”到 widget 中，我们要关掉各种边框和标题栏。更重要的是，我们要将微博秀的背景色设置成与主题一致。
在ejs前后加入
```xml
  <div class="widget-wrap">
    <h3 class="widget-title">Weibo</h3>
    <div class="widget">
```
和
```xml
  </div>
</div>
```
此时外框带有一个`padding`值，使得微博秀显示在其中小了一圈，我们希望将微博秀贴边显示。这个padding值正是由`widget`这个 class 的 CSS 设定的。
所以在第三行的 div 中指定 padding 值覆盖 css 中的设定。
```xml
<div class="widget" style="padding: 0px">
```


##13. 侧栏 Archive 组件修改 ##
该组件列出所有有日志的月份索引，但月在前，与国内习惯不同。且当日志较多时可能会很长。故修改日期格式并限制长度。
注意，该修改涉及 Hexo 源代码,是插件目录下 helper 中的一部分，而不仅是本主题的代码。
`\node_modules\hexo\lib\plugins\helper\list_archives.js`
23行，日期格式，由`MMMM YYYY`改为`YYYY - MM`。

将70行起的 if 区块代码改为：
```javascript
result += '<ul class="' + className + '-list">';
len = data.length < 10 ? data.length : 9;
for (i = 0; i < len; i++){
  item = data[i];

  result += '<li class="' + className + '-list-item">';

  result += '<a class="' + className + '-list-link" href="' + link(item) + '">';
  result += transform ? transform(item.name) : item.name;
  result += '</a>';

  if (showCount){
    result += '<span class="' + className + '-list-count">' + item.count + '</span>';
  }

  result += '</li>';
}
if (data.length > 9) result += '<br><a href="' + self.url_for(archiveDir) + '">查看更多...</a>';

result += '</ul>';
```

##14. 搜索改为 [Tinysou](http://tinysou.com/) ##
先去官网创建个引擎，然后在“爬虫”那把自己的域名添加进去。
新建个`tinysou.ejs`文件，把提供的代码粘贴进去，保存后放到`layout\_partial`目录下。

`layout\_partial\after-footer.ejs`,在最后一行加入`<%- partial('tinysou') %>`
修改搜索框涉及 Helper。
`node_modules\hexo\lib\plugins\helper\search_form.js`
12行起改为：
```javascript
  return '<form class="' + className + '">' +
    '<input type="input" id="ts-search-input" name="q" results="0" class="' + className + '-input"' + (text ? ' placeholder="' + text + '"' : '') + '>' +
    (button ? '<button type="submit" class="' + className + '-submit">' + (typeof button === 'string' ? button : text) + '</button>' : '') +
    '</form>';
```

##15. 头部加入社交入口 ##
`layout\_partial\header.ejs` 22 行加入
```xml
<a class="nav-icon" href="http://weibo.com/3904642734" title="微博" target="_blank">&#61834;</a>
<a class="nav-icon" href="http://www.renren.com/287137027" title="人人" target="_blank">&#61835;</a>
<a class="nav-icon" href="http://user.qzone.qq.com/525969441" title="QQ空间" target="_blank">&#61910;</a>
<a class="nav-icon" href="https://www.facebook.com/sykiechencixi" title="Facebook" target="_blank">&#62000;</a>
<a class="nav-icon" href="https://twitter.com/HKEY_C17" title="twitter" target="_blank">&#61593;</a>
<a class="nav-icon" href="http://www.linkedin.com/in/sykiechen" title="LinkedIn" target="_blank">&#61665;</a>
<a class="nav-icon" href="https://github.com/sykiechen" title="GitHub" target="_blank">&#61595;</a>
<a class="nav-icon" href="https://plus.google.com/118157846818083514683" title="Google+" target="_blank">&#61653;</a>
```

##16. [关于、友链](http://howiefh.github.io/2014/04/20/hexo-optimize-and-my-theme-landscape-f/) ##
添加了`links.ejs`、`about_me.ejs`、`about_me.styl`并在`style.styl`中添加相关引用。

##17. [返回顶部](http://howiefh.github.io/2014/04/20/hexo-optimize-and-my-theme-landscape-f/)
```
modified:   layout/_partial/after-footer.ejs
modified:   source/css/_variables.styl
modified:   source/css/style.styl
add layout/_partial/bottomBtn.ejs
add source/css/_partial/bottombtn.styl
add source/js/gotop.js
```

##18. [文章目录](http://starsky.gitcafe.io/2015/05/06/%E4%B8%BAHexo%E5%8D%9A%E6%96%87%E6%B7%BB%E5%8A%A0%E6%96%87%E7%AB%A0%E7%9B%AE%E5%BD%95/)##

`layout\_partial\article.ejs`
```javascript
<% } else { %>
	<!-- Table of Contents -->
	<% if (!index && post.toc){ %>
		<div id="toc" class="toc-article">
			<strong class="toc-title">文章目录</strong>
    		<%- toc(post.content) %>
		</div>
	<% } %>
	<%- post.content %>
```

`source\css\_partial\article.styl`
```css
/*toc*/
.toc-article
  background #eee
  border 1px solid #bbb
  border-radius 10px
  margin 1.5em 0 0.3em 1.5em
  padding 1.2em 1em 0 1em
  max-width 28%
.toc-title
  font-size 120%
#toc
  line-height 1em
  font-size 0.9em
  float right
  .toc
    padding 0
    margin 1em
    line-height 1.8em
    li
      list-style-type none
  .toc-child 
    margin-left 1em

```
在需要目录的文章 md 中加入参数`toc: true`

## 19. 将文章时间放在标题下 ##
`article.ejs`
```xml
      </header>
    <% } %>
  <div class="article-meta">
    <%- partial('post/date', {class_name: 'article-date', date_format: 'YYYY-M-D ddd  HH:mm'}) %>
    <%- partial('post/category') %>
  </div>

    <div class="article-entry" itemprop="articleBody">
```

`article.styl`
```css
.article-date
  @extend $block-caption
  margin: 20px 15px 0px 15px
  float: left
  a&:hover
    color: color-link
  &:before
    font-family: font-icon
    color: #ccc
    content: "\f073"

.article-category
  margin: 15px 15px 0px 8px
  float: left
  line-height: 1em
  color: #ccc
  text-shadow: 0 1px #fff
  &:before
    font-family: font-icon
    content: "\f0c6"
```
```css
.article-date
  @extend $block-caption
  margin: 15px 15px 0px 20px
  float: left
  a&:hover
    color: color-link
  &:before
    font-family: font-icon
    color: #ccc
    content: "\f073"

.article-category
  margin: 15px 15px 0px 8px
  float: left
  line-height: 1em
  color: #ccc
  text-shadow: 0 1px #fff
  &:before
    font-family: font-icon
    content: "\f0c6"
```

## 20. [在某些图片上禁用 fancybox](http://twiceyuan.com/2014/08/12/disable-fancybox/) ##

有些情况下希望某些图片不使用 fancybox 的弹出效果，如关于页面中的网站小图标，在 hexo 中可以这样实现：

`/source/js/script.js`,找到：
```javascript
// Caption
  $('.article-entry').each(function(i){
    $(this).find('img').each(function(){
      if ($(this).parent().hasClass('fancybox')) return;

      var alt = this.alt;

      if (alt) $(this).after('<span class="caption">' + alt + '</span>');

      $(this).wrap('<a href="' + this.src + '" title="' + alt + '" class="fancybox"></a>');
    });

    $(this).find('.fancybox').each(function(){
      $(this).attr('rel', 'article' + i);
    });
  });

  if ($.fancybox){
    $('.fancybox').fancybox();
  }
```
在 `if ($(this).parent().hasClass('fancybox')) return;` 下插入 `if ($(this).hasClass('nofancybox')) return;` 意思为如果遇到 nofancybox 类则跳过，这样在不需要 fancybox 显示 img 标签上的 class 改为 nofancybox 就可以禁用 fancybox 了。

## 后记 ##
&emsp;&emsp;终于造好了轮子= = 整个人都萌了许多
&emsp;&emsp;bug 在所难免，本项目 GitHub 主页：
https://github.com/sykiechen/hexo-theme-hic17
&emsp;&emsp;（我知道，没人会去看的=。=）
&emsp;&emsp;但我还是觉得我萌了好多！![](http://www.devchen.com/css/images/tavatar.png)


<p align = right>
by Sykie Chen
2015.5.23
</p>