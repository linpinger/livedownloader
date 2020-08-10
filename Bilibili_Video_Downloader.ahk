; 用途: 萌萌哒 @ 2020-07-03: depend: curl,wget,ffmpeg
	#NoEnv
	wDir := General_getWDir() ; T:\, A_WorkingDir

;	AddStr := "--limit-rate=600k"

	bDebug := true
	bBatMode := true

	UA := "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:77.0) Gecko/20100101 Firefox/77.0"
;	pageURL := "https://www.bilibili.com/video/BV1Ma4y1e7R6"
^esc::reload
+esc::Edit
!esc::ExitApp
F1::
	mayURL := Clipboard
	if ( InStr(mayURL, "https://www.bilibili.com/video/") ) {
		pageURL := mayURL
	} else {
		msgbox, 网址貌似不对`n%mayURL%
		return
	}

	runwait, curl -o toc.html --compressed -H "%UA%" "%pageURL%", %wDir%, min

	FileRead, html, *P65001 %wDir%\toc.html
	if ( ! bDebug )
		FileDelete, %wDir%\toc.html

	ff_1 := "", ff_2 := ""
	RegExMatch(html, "smUi)<script>[^={]+=(.*)</script>.*""title"":""([^""]+)""", FF_) ; json, title
	if ( bDebug )
		FileAppend, %FF_1%, %wDir%\toc.json
	if ( "" = FF_1 ) {
		msgbox, 解析网页json数据为空，应该不是正常视频
		return
	}
	j := JSON.parse(FF_1)
	title := FF_2

; msgbox, % "即将下载: " title "`n`n" pageURL

	batName := "bv_" . A_Now
	oStr := "mkdir " . batName . "`ncd " . batName . "`n`n"
	; 获取音频
	aURL := ""
	for k, v in j.data.dash.audio
	{
;		msgbox, % "id=" v.id "  bandwidth=" v.bandwidth "  url=" v.baseUrl  ; base_url
		if ( "30280" = v.id ) {
			aURL := v.baseUrl
		}
	}
	if ( "" = aURL )
		msgbox, audio URL 解析错误，为空

	oStr .= "wget -O audio.m4s -c " . AddStr . " --referer=""https://www.bilibili.com/"" """ . aURL . """`n"
	if ( ! bBatMode )
		runwait, wget -O audio.m4s -c %AddStr% --referer="https://www.bilibili.com/" "%aURL%", %wDir%, min

	; 获取视频
	vURL := ""
	for k, v in j.data.dash.video
	{
;		msgbox, % v.id "  " v.codecid "`n" v.bandwidth "`n" v.width " x " v.height
		if ( "720" = v.height and "7" = v.codecid ) {
			vURL := v.baseUrl
		}
	}
	if ( "" = vURL )
		msgbox, video URL 解析错误，为空

	oStr .= "wget -O video.m4s -c " . AddStr . " --referer=""https://www.bilibili.com/"" """ . vURL . """`n`n"
	if ( ! bBatMode )
		runwait, wget -O video.m4s -c %AddStr% --referer="https://www.bilibili.com/" "%vURL%", %wDir%, min

	
	; 合并音频视频
	oStr .= "ffmpeg -i audio.m4s -i video.m4s -vcodec copy -acodec copy -movflags faststart bilibili.mp4`n`n"
	if ( ! bBatMode )
		runwait, ffmpeg -i audio.m4s -i video.m4s -vcodec copy -acodec copy -movflags faststart bilibili.mp4, %wDir%, min
	oStr .= "del audio.m4s`ndel video.m4s`nmove bilibili.mp4 ..`ncd ..`nmove bilibili.mp4 """ . title . ".mp4""`nrmdir " . batName . "`n"
	if ( ! bBatMode )
		FileMove, %wDir%\bilibili.mp4, %wDir%\%title%.mp4
	if ( ! bDebug ) {
		if ( ! bBatMode ) {
			FileDelete, %wDir%\audio.m4s
			FileDelete, %wDir%\video.m4s
		}
	}

	if ( bBatMode ) {
		FileAppend, %oStr%, %wDir%\%batName%.bat
		run, %batName%.bat, %wDir%
	}
	TrayTip, 完毕:, %title%
return

#Include <JSON_Class>

/*

# 页面包含 m4s地址
https://www.bilibili.com/video/BV1pT4y177Gr

# 下载视音
wget -O video.m4s -c --referer="https://www.bilibili.com/" "https://cn-gdfs2-cmcc-v-01.bilivideo.com/upgcxcode/10/22/205932210/205932210_nb2-1-30080.m4s?expires=1593170201&platform=pc&ssig=tG8Le4RLkzgwLcCsrsDiUg&oi=3085837402&trid=f8744f7a724e47b5a84c203426aefb36u&nfc=1&nfb=maPYqpoel5MI3qOUX6YpRA==&cdnid=9913&mid=44547971&orderid=0,3&logo=80000000"
wget -O audio.m4s -c --referer="https://www.bilibili.com/" "https://cn-gdfs2-cmcc-v-10.bilivideo.com/upgcxcode/10/22/205932210/205932210_nb2-1-30280.m4s?expires=1593170201&platform=pc&ssig=5kT2MmSr8vifutXbVghDdg&oi=3085837402&trid=f8744f7a724e47b5a84c203426aefb36u&nfc=1&nfb=maPYqpoel5MI3qOUX6YpRA==&cdnid=11321&mid=44547971&orderid=0,3&logo=80000000"

# 合并音视轨
ffmpeg -i audio.m4s -i video.m4s -vcodec copy -acodec copy -movflags faststart out.mp4

*/

/*
; 用途: bilibili_Cache_2mp4 @ 2020-06-24
	
	wDir := "T:\"

	if ( true ) { ; 临时文件放到这里
		EnvSet, TEMP, %wDir%
		EnvSet, TMP, %wDir%
	}
	TrayTip, 热键:, Ctrl + H: http`nF1: 合并音视频轨

^esc::reload
+esc::Edit
!esc::ExitApp
F1::
	gosub, DetectFile
	gosub, json2Name

	runwait, ffmpeg -i audio.m4s -i video.m4s -vcodec copy -acodec copy -movflags faststart %oName%, %wDir%, min
return
^h:: run, http -p 23333 -U Linux, %wDir%, min

json2Name:
	FileRead, jsonStr, *P65001 %wDir%\entry.json
	FF_1 := "" , FF_2 := ""
	RegExMatch(jsonStr, "Ui)""title"":""([^""]+)"".*""avid"":([0-9]+),", FF_)
	msgbox, % ff_1 "`n" ff_2
	oName := FF_2 . "_" . FF_1 . ".mp4"
return

DetectFile:
	IfNotExist, %wDir%\entry.json
	{
		msgbox, 不存在 entry.json
		return
	}
	IfNotExist, %wDir%\audio.m4s
	{
		msgbox, 不存在 audio.m4s
		return
	}
	IfNotExist, %wDir%\video.m4s
	{
		msgbox, 不存在 video.m4s
		return
	}
return

*/
