# 一些下载工具

**名称:** FoxBook

**功能:** 直播或音视频下载

**作者:** 爱尔兰之狐(linpinger)

**邮箱:** <mailto:linpinger@gmail.com>

**主页:** <http://linpinger.github.io?s=LiveDownloader_MD>

**缘起:** 用别人写的工具，总感觉不能随心所欲，于是自己写

**原理:** 下载网页，分析网页，获取下载地址


## 依赖程序下载地址
- wget: (https://eternallybored.org/misc/wget/)
- ffmpeg: (https://ffmpeg.zeranoe.com/builds/)
- mkvtoolnix: (https://www.fosshub.com/MKVToolNix.html)

## ximalaya.ahk

- 功能: 批量下载喜马拉雅的免费音频（理论可以用VIP账号的cookie下载VIP，未测试）

- 核心: 本脚本中的解密代码翻译自: (https://github.com/stephenwu2020/ximalaya-dl)

- 流程: 
  - 类似地址: `https://www.ximalaya.com/youshengshu/4256765/` 得到 albumId : `4256765`
  - 通过 `GetAudioInfo(4256765)` 获取json里面的data.src的播放地址
  - 如果该地址为空，调用 `GetVipAudioInfo(4256765)` 获取播放地址，这里就会用到解密函数来获取文件名，下载地址等
  - 然后调用wget来下载m4a/mp3，其他代码就是GUI相关

- 依赖: `wget.exe` `JSON_Class.ahk`

## 2mp4.ahk

- 功能: 调用 `ffmpeg` 或 `mkvtoolnix` 将flv合并或转为mp4，或提取音频，不涉及转码，只更换容器，所以速度快
- 依赖: `ffmpeg.exe` `mkvtoolnix`中的`mkvmerge`

## MGTV_Video_Downloader.ahk
- 功能: 下载芒果tv的m3u8，生成下载批处理文件
- 用法: 
  - 使用浏览器的开发工具的网络标签，过滤m3u8，复制该url到剪贴板
  - F1下载该m3u8生成bat，或者
    - 给脚本创建快捷方式，在参数后加入 ` GUI`，双击脚本
  - 双击bat下载*.ts
  - `cat *.ts > ../a.ts`
  - 使用2mp4.ahk转为mp4即可

## DouYin_Live.ahk
- 功能: 下载抖音直播
- 用法: 
  - 打开抖音app，打开想下载的直播，点击分享链接
  - 链接已在手机剪贴板中，发送到电脑
  - 打开脚本，点击按钮: ShareURL，jsonURL，会在 flvURL后面的编辑框内显示flv地址，该地址即为该直播的推流地址
  - 点击下载FLV或者循环下载（防止主播掉线，或网络故障）

## bilibili_Live_Template.ahk
- 功能: 下载B站直播
- 用法: 
  - 修改: 第4行的 `HeadName := "xxxxxxx"` 中的 xxxxxxx 为up主名或拼音
  - 修改: 第5行的 `RoomID := "nnnnnnn"` 中的 nnnnnnn 为直播房间号
  - 保存，双击脚本即可下载

## Bilibili_Video_Downloader.ahk
- 功能: 下载B站视频
- 用法:
  - 浏览器中复制视频网址到剪贴板，例如: `https://www.bilibili.com/video/BV1tZ4y1M7xe`
  - 双击本脚本，并按键盘F1键，会下载高清版的视频和音频，然后自动调用ffmpeg合并为mp4

**更新日志:**
- 2020-08-10: 第一次提交

