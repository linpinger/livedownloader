# 一些下载工具

**名称:** FoxBook

**功能:** 直播或音视频下载

**作者:** 爱尔兰之狐(linpinger)

**邮箱:** <mailto:linpinger@gmail.com>

**主页:** <http://linpinger.github.io?s=LiveDownloader_MD>

**缘起:** 用别人写的工具，总感觉不能随心所欲，于是自己写

**原理:** 下载网页，分析网页，获取下载地址

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

**更新日志:**
- 2020-08-10: 添加: ximalaya.ahk 下载喜马拉雅专辑

