; 用途: 萌萌哒 @ 2020-08-12

	Arg1 = %1%

bDebug := false

	wDir := General_getWDir() ; T:\, A_WorkingDir
	SetWorkingDir, %wDir%

	refURL  := "https://www.mgtv.com/"

	if ( "GUI" = Arg1 ) {
		InputBox, PageURL, URL, 输入播放地址的URL, , , , , , , , %Clipboard%
		video_id := ""
		if ( InStr(PageURL, ".mgtv.com/b/") and InStr(PageURL, ".html") ) {
			RegExMatch(PageURL, "Ui)mgtv.com/b/[0-9]+/([0-9]+)\.html", vid_)
			video_id := vid_1, vid_1 := ""
		}

		if ( "" != video_id )
			gosub, Stage1_VideoID2PM
		ExitApp
	}

	TrayTip, 热键:, F1: URL2bat
return

copyURL2Clip:
	IfWinExist, ahk_class MozillaWindowClass
	{	; 复制当前网址
		WinActivate, ahk_class MozillaWindowClass
		WinWaitActive, ahk_class MozillaWindowClass
		Clipboard =
		send !d
		sleep 500
		send ^c
		ClipWait
	}

	video_id := ""
	; https://www.mgtv.com/b/338481/8278568.html
	; video_id := "8278568"

	if ( InStr(Clipboard, ".mgtv.com/b/") and InStr(Clipboard, ".html") ) {
		RegExMatch(Clipboard, "Ui)mgtv.com/b/[0-9]+/([0-9]+)\.html", vid_)
		video_id := vid_1, vid_1 := ""
	}

	if ( "" != video_id )
		gosub, Stage1_VideoID2PM
return


Stage1_VideoID2PM: ; 输入:video_id，输出: PM_CHKID, PM2, video_id
;	video_id := "9430799"
	jsonpName := "jsonp_" . General_getUnixTime() . "000_23333"
	TK2 := getTK2()

	runwait, wget --save-headers -t 3 -T 5 -O mgtv_video.json "https://pcweb.api.mgtv.com/player/video?video_id=%video_id%&type=pch5&_support=10000000&auth_mode=1&callback=%jsonpName%&tk2=%TK2%", , min
	FileRead, httpStr, *P65001 mgtv_video.json
	if ( ! bDebug )
		FileDelete, mgtv_video.json

	RegExMatch(httpStr, "smUi)PM_CHKID=([^ `;]+)`;", chkid_)
	RegExMatch(httpStr, "smUi)""pm2"":""([^""]+)""", pmt_)
	PM_CHKID := chkid_1, chkid_1 := ""
	PM2 := pmt_1, pmt_1 := ""
	; 输出: PM_CHKID, PM2, video_id

	gosub, Stage2_getSource
return

Stage2_getSource: ; 输入: PM_CHKID, PM2, video_id   输出: M3U8URL
	jsonpName := "jsonp_" . General_getUnixTime() . "000_23333"
	runwait, wget -O mg_1.json "https://pcweb.api.mgtv.com/player/getSource?pm2=%PM2%&video_id=%video_id%&type=pch5&callback=%jsonpName%" --header="Cookie: PM_CHKID=%PM_CHKID%", , min
	FileRead, jsonStr, *P65001 mg_1.json
	if ( ! bDebug )
		FileDelete, mg_1.json
	if ( "" = jsonStr )
		msgbox, % "空json: mg1"

	staPos := InStr(jsonStr, "{")
	endPos := InStr(jsonStr, "}", fase, 0)
	jsonStr := SubStr(jsonStr, staPos, endPos - staPos + 1)
	j := JSON.parse(jsonStr)
	jURL2 := ""
	uHead := j.data.stream_domain[1]
	for i, v in j.data.stream
	{
		if ( "超清" = v.name ) {
			jURL2 := uHead . v.url
			break
		}
	}

	runwait, wget -O mg_2.json "%jURL2%", , min
	FileRead, jsonStr, *P65001 mg_2.json
	if ( ! bDebug )
		FileDelete, mg_2.json

	if ( "" = jsonStr)
		msgbox, % "空json: mg2"

	j := JSON.parse(jsonStr)
	m3u8URL := j.info
;	msgbox, % m3u8URL

	gosub, Stage3_DownM3U8
return

Stage3_DownM3U8: ; in: M3U8URL, video_id   out: m3u8Content, BaseURL
	if ( ! InStr(M3U8URL, ".m3u8") ) {
		TrayTip, 错误:, 不包含.m3u8地址
		sleep 2000
		return
	}

	wDir := General_getWDir() . "\" . video_id ; A_TickCount
	FileCreateDir, %wDir%

	; 分析得到两地址
	ff_1 := "", ff_2 := ""
	RegExMatch(M3U8URL, "smi)((http[^\?]+/)[^/\.]+\.m3u8?[^""]+)", ff_) ; url, dir
	M3U8_URL := FF_1
	BaseURL := FF_2

	M3U8_Name := "00_" . A_now . ".m3u8"
	runwait, wget -O %M3U8_Name% --referer=%refURL% "%M3U8_URL%", %wDir%, min
	FileRead, m3u8Content, %wDir%\%M3U8_Name%
	if ( ! InStr(m3u8Content, "#EXT-X-ENDLIST") ) {
		traytip, 错误:, m3u8内容不正确
		return
	}

	gosub, Stage4_ts2bat
return

Stage4_ts2bat: ; in: m3u8Content, BaseURL
;	BaseURL := ""
;	FileRead, m3u8Content, T:\00\00.m3u8
	oStr := ""
	count := 1000
	loop, parse, m3u8Content, `n, `r
	{
		if ( ! InStr(A_LoopField, "mp4.ts") )
			continue
		++ count
		oStr .= "wget -c -t 3 -T 9 --referer=" . refURL . " -O " . count . ".ts """ . BaseURL . A_LoopField . """`n"
	}
	oStr .= "`necho cat *.ts > ..\00.ts`n"
	FileAppend, %oStr%, %wDir%\00.bat
	traytip, ok:, %wDir%\00.bat
return

^esc::reload
+esc::Edit
!esc::ExitApp
F1:: gosub, copyURL2Clip

#Include <General>
#Include <base64>
#Include <JSON_Class>

; wget --referer=https://www.mgtv.com/ -O 000.ts "url"
; cat *.ts > ..\00.ts
; ts -> mp4

reverseString(iStr){ ; 字符串调转字符方向
	oStr := ""
	loop, parse, iStr
		oStr := A_LoopField . oStr
	return oStr
}

getTK2() {
	global Chars
	STKUUID := "00000000-0000-0000-0000-000000000000"
	strA := "did=" . STKUUID . "|pno=1030|ver=0.3.0301|clit=" . General_getUnixTime()

	oldStringCaseSense := A_StringCaseSense
	StringCaseSense On 
	Chars = ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/
	strB := Base64(strA)
	StringCaseSense %oldStringCaseSense%

	StringReplace, strB, strB, +, _, A
	StringReplace, strB, strB, /, ~, A
	StringReplace, strB, strB, =, -, A

	return, reverseString(strB)
}



