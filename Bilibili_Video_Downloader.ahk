; ��;: ������ @ 2020-07-03: depend: curl,wget,ffmpeg
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
		msgbox, ��ַò�Ʋ���`n%mayURL%
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
		msgbox, ������ҳjson����Ϊ�գ�Ӧ�ò���������Ƶ
		return
	}
	j := JSON.parse(FF_1)
	title := FF_2

; msgbox, % "��������: " title "`n`n" pageURL

	batName := "bv_" . A_Now
	oStr := "mkdir " . batName . "`ncd " . batName . "`n`n"
	; ��ȡ��Ƶ
	aURL := ""
	for k, v in j.data.dash.audio
	{
;		msgbox, % "id=" v.id "  bandwidth=" v.bandwidth "  url=" v.baseUrl  ; base_url
		if ( "30280" = v.id ) {
			aURL := v.baseUrl
		}
	}
	if ( "" = aURL )
		msgbox, audio URL ��������Ϊ��

	oStr .= "wget -O audio.m4s -c " . AddStr . " --referer=""https://www.bilibili.com/"" """ . aURL . """`n"
	if ( ! bBatMode )
		runwait, wget -O audio.m4s -c %AddStr% --referer="https://www.bilibili.com/" "%aURL%", %wDir%, min

	; ��ȡ��Ƶ
	vURL := ""
	for k, v in j.data.dash.video
	{
;		msgbox, % v.id "  " v.codecid "`n" v.bandwidth "`n" v.width " x " v.height
		if ( "720" = v.height and "7" = v.codecid ) {
			vURL := v.baseUrl
		}
	}
	if ( "" = vURL )
		msgbox, video URL ��������Ϊ��

	oStr .= "wget -O video.m4s -c " . AddStr . " --referer=""https://www.bilibili.com/"" """ . vURL . """`n`n"
	if ( ! bBatMode )
		runwait, wget -O video.m4s -c %AddStr% --referer="https://www.bilibili.com/" "%vURL%", %wDir%, min

	
	; �ϲ���Ƶ��Ƶ
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
	TrayTip, ���:, %title%
return

#Include <JSON_Class>

/*

# ҳ����� m4s��ַ
https://www.bilibili.com/video/BV1pT4y177Gr

# ��������
wget -O video.m4s -c --referer="https://www.bilibili.com/" "https://cn-gdfs2-cmcc-v-01.bilivideo.com/upgcxcode/10/22/205932210/205932210_nb2-1-30080.m4s?expires=1593170201&platform=pc&ssig=tG8Le4RLkzgwLcCsrsDiUg&oi=3085837402&trid=f8744f7a724e47b5a84c203426aefb36u&nfc=1&nfb=maPYqpoel5MI3qOUX6YpRA==&cdnid=9913&mid=44547971&orderid=0,3&logo=80000000"
wget -O audio.m4s -c --referer="https://www.bilibili.com/" "https://cn-gdfs2-cmcc-v-10.bilivideo.com/upgcxcode/10/22/205932210/205932210_nb2-1-30280.m4s?expires=1593170201&platform=pc&ssig=5kT2MmSr8vifutXbVghDdg&oi=3085837402&trid=f8744f7a724e47b5a84c203426aefb36u&nfc=1&nfb=maPYqpoel5MI3qOUX6YpRA==&cdnid=11321&mid=44547971&orderid=0,3&logo=80000000"

# �ϲ����ӹ�
ffmpeg -i audio.m4s -i video.m4s -vcodec copy -acodec copy -movflags faststart out.mp4

*/

/*
; ��;: bilibili_Cache_2mp4 @ 2020-06-24
	
	wDir := "T:\"

	if ( true ) { ; ��ʱ�ļ��ŵ�����
		EnvSet, TEMP, %wDir%
		EnvSet, TMP, %wDir%
	}
	TrayTip, �ȼ�:, Ctrl + H: http`nF1: �ϲ�����Ƶ��

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
		msgbox, ������ entry.json
		return
	}
	IfNotExist, %wDir%\audio.m4s
	{
		msgbox, ������ audio.m4s
		return
	}
	IfNotExist, %wDir%\video.m4s
	{
		msgbox, ������ video.m4s
		return
	}
return

*/
