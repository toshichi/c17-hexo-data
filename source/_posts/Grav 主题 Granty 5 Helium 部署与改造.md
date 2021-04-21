---
title: Grav 主题 Granty 5 Helium 部分修复与改造[弃坑]
date: 2020-05-17 19:43
tags: [Grav, Helium]
category: Services
id: grav-helium-mod
cover: .images/Grav%20主题%20Granty%205%20Helium%20部署与改造/image-20200517194323886.png
---

## 1. Header Owl Carousel 副标题 Tablet 宽度下错位溢出问题

`user\data\gantry5\themes\g5_helium\scss\custom.scss`

``` scss
// fix header subtitle overflow in tablet view
// user\themes\g5_helium\scss\helium\particles\_owlcarousel.scss:378
@media only all and (max-width: 59.99rem) and (min-width: 48rem){
    .g-owlcarousel .g-owlcarousel-item-wrapper .g-owlcarousel-item-content-container .g-owlcarousel-item-content-wrapper .g-owlcarousel-item-content {
        padding-top: 0
    }
}
```



## 2. Mobile 宽度下菜单栏和 logo 位置错位问题

导航栏空白太大，将 Navigation 的部分设置 nomarginall 和 nopaddingall 后引起移动端错位，在此修正。

![image-20200517194323886](.images/Grav%20主题%20Granty%205%20Helium%20部署与改造/image-20200517194323886.png)

`user\data\gantry5\themes\g5_helium\scss\custom.scss`

``` scss
// fix menu icon position on mobile view
// user\themes\g5_helium\scss\helium\sections\_offcanvas.scss:45
.g-offcanvas-toggle{
    top: 0.7rem
}

// gix logo position on mobile view
// user\themes\g5_helium\scss\helium\particles\_logo.scss:25
@media only all and (max-width: 47.99rem){
    .g-logo {
        margin: 0;
    }
}
```



## 3. 导航栏滚动固定

使用 [Fixed_Sticky Header Atoms for Gantry 5 (FREEBIES)](https://www.inspiretheme.com/blog/freebies/42-fixed-sticky-header-atoms-for-gantry-5-freebies) 实现



