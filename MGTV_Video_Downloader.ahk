; 用途: 萌萌哒 @ 2020-08-12
	verDate := "2020-08-22"

	bDebug := false
	wDir := General_getWDir() ; T:\, A_WorkingDir
	SetWorkingDir, %wDir%

DefCIDList=
(join|
338497_乘风破浪的姐姐
334727_快乐大本营
338481_妻子的浪漫旅行
338575_婆婆和妈妈
337284_向往的生活
)

	refURL  := "https://www.mgtv.com/"

	gosub, MenuInit
	gosub, GuiInit
return

GuiInit:
	Gui, Add, GroupBox, x12 y10 w800 h50 cBlue, Album | Month | CID | VID
	Gui, Add, ComboBox, x22 y30 w270 h20 R9 vCIDList choose1, %DefCIDList%
	Gui, Add, ComboBox, x302 y30 w118 h20 R20 vMonthList choose1, %A_YYYY%%A_MM%
	Gui, Add, Edit, x442 y30 w110 h20 vCID
	Gui, Add, Edit, x572 y30 w110 h20 vVideo_ID

	Gui, Add, ListView, x12 y70 w800 h300 vFoxLV gClickLV, VID|Title2|Time|Title3|VIP
		LV_ModifyCol(1, 70), LV_ModifyCol(2, 100), LV_ModifyCol(3, 50), LV_ModifyCol(4, 500), LV_ModifyCol(5, 40)
	; Generated using SmartGUI Creator 4.0
	Gui, Show, h380 w825, MGTV   Ver: %verDate%
Return

getFirstList:
	GuiControlGet, MonthList
	GuiControlGet, CIDList
	StringSplit, CCID_, CIDList, _, %A_Space%  ; 338497_乘风破浪的姐姐
	CID := CCID_1
	GuiControl, text, CID, %CID%

;			https://pcweb.api.mgtv.com/list/master?_support=10000000&filterpre=true&vid=&cid=338481&pn=1&ps=60&month=202006&&callback=jsonp_1597213967080_49296
	url := "https://pcweb.api.mgtv.com/list/master?cid=" . cid
	if ( "" != MonthList )
		url .= "&filterpre=true&pn=1&ps=60&month=" . MonthList

	fName := "mgtv_list_" . cid . ".json"
	IfNotExist, %fName%
		runwait, wget -t 3 -T 5 -O %fName% "%url%", , min
	FileRead, jsonStr, *P65001 %fName%
	if ( ! bDebug )
		FileDelete, %fName%
	j := JSON.parse(jsonStr)

	; 各季
	loop, % j.data.tab_y.MaxIndex()
	{
		nowCID := j.data.tab_y[A_index].id
		if ( nowCID != CID )
			GuiControl, , CIDList, % nowCID . "_" . j.data.tab_y[A_index].t . " @ " . CCID_2
	}

	; 各月
	GuiControl, , MonthList, |
	loop, % j.data.tab_m.MaxIndex()
		GuiControl, , MonthList, % j.data.tab_m[A_index].m
;	GuiControl, Choose, MonthList, 1

	; 各集
	for i, v in j.data.list
		LV_Add("", v.video_id, v.t2, v.time, v.t3, v.isvip)
	if ( "" != MonthList )
		LV_Add("", "", MonthList, "", "-- 以上是 " MonthList " 的内容 --")
	else
		LV_Add()
return


copyURL2Clip:
	if ( ! InStr(Clipboard, ".mgtv.com/b/") ) {
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
		gosub, ClipURL2VID
	}
return

ClipURL2VID:
	video_id := "" ; https://www.mgtv.com/b/338481/8278568.html ; video_id := "8278568"

	if ( InStr(Clipboard, ".mgtv.com/b/") and InStr(Clipboard, ".html") ) {
		RegExMatch(Clipboard, "Ui)mgtv.com/b/[0-9]+/([0-9]+)\.html", vid_)
		video_id := vid_1, vid_1 := ""
	}

	if ( "" != video_id ) {
		GuiControl, text, video_id, %video_id%
		gosub, Stage1_VideoID2PM
	}
return

Stage1_VideoID2PM: ; 输入:video_id，输出: PM_CHKID, PM2, video_id
;	video_id := "9430799"
	TK2 := getTK2()

;	jsonpName := "jsonp_" . General_getUnixTime() . "000_23333"
;	runwait, wget --save-headers -t 3 -T 5 -O mgtv_video.json "https://pcweb.api.mgtv.com/player/video?video_id=%video_id%&type=pch5&_support=10000000&auth_mode=1&callback=%jsonpName%&tk2=%TK2%", , min
	runwait, wget --save-headers -t 3 -T 5 -O mgtv_video.json "https://pcweb.api.mgtv.com/player/video?video_id=%video_id%&type=pch5&_support=10000000&auth_mode=1&tk2=%TK2%", , min
	FileRead, httpStr, *P65001 mgtv_video.json
	if ( ! bDebug )
		FileDelete, mgtv_video.json

	RegExMatch(httpStr, "smUi)PM_CHKID=([^ `;]+)`;", chkid_)
	RegExMatch(httpStr, "smUi)""pm2"":""([^""]+)""", pmt_)
	RegExMatch(httpStr, "smUi)""tk2"":""([^""]+)""", tk_)
	PM_CHKID := chkid_1, chkid_1 := ""
	PM2 := pmt_1, pmt_1 := ""
	TK2 := tk_1, tk_1 := ""
	; 输出: PM_CHKID, PM2, video_id, TK2

;	msgbox, % PM_CHKID "`n" PM2 "`n" video_id "`n" TK2
	gosub, Stage2_getSource
return

Stage2_getSource: ; 输入: PM_CHKID, PM2, video_id, TK2   输出: M3U8URL
;	jsonpName := "jsonp_" . General_getUnixTime() . "000_23333"
	runwait, wget -O mg_1.json "https://pcweb.api.mgtv.com/player/getSource?tk2=%TK2%&pm2=%PM2%&video_id=%video_id%&type=pch5" --header="Cookie: PM_CHKID=%PM_CHKID%", , min
	FileRead, jsonStr, *P65001 mg_1.json
	if ( ! bDebug )
		FileDelete, mg_1.json
	if ( "" = jsonStr )
		msgbox, % "空json: mg1"
	if ( InStr(jsonStr, "参数错误") ) {
		clipboard = wget -O mg_1.json "https://pcweb.api.mgtv.com/player/getSource?tk2=%TK2%&pm2=%PM2%&video_id=%video_id%&type=pch5" --header="Cookie: PM_CHKID=%PM_CHKID%"
		msgbox, 参数错误mg1
	}

;	staPos := InStr(jsonStr, "{")
;	endPos := InStr(jsonStr, "}", fase, 0)
;	jsonStr := SubStr(jsonStr, staPos, endPos - staPos + 1)
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

ClickLV: ; 点击LV
	nRow := A_EventInfo
	if ( A_GuiEvent = "DoubleClick" ) {
		LV_GetText(video_id, nRow, 1)
		GuiControl, text, video_id, %video_id%
		if ( "" != video_id )
			gosub, Stage1_VideoID2PM
	}
return

MenuInit:
	Menu, MyMenuBar, Add, 清空LV(&C), MenuAct
	Menu, MyMenuBar, Add, 　　　　　　　, MenuAct
	Menu, MyMenuBar, Add, 获取列表(&S), MenuAct
	Menu, MyMenuBar, Add, 　　　　　　　　, MenuAct
	Menu, MyMenuBar, Add, 下载视频ID(&D), MenuAct
	Menu, MyMenuBar, Add, 从剪贴板获取视频ID(&V), MenuAct
	Menu, MyMenuBar, Add, 从FireFox获取视频ID(&F), MenuAct
	Gui, Menu, MyMenuBar
return

MenuAct:
	if ( "获取列表(&S)" = A_ThisMenuItem ) {
		gosub, getFirstList
	} else if ( "清空LV(&C)" = A_ThisMenuItem ) {
		LV_Delete()
	} else if ( "下载视频ID(&D)" = A_ThisMenuItem ) {
		GuiControlGet, video_id
		if ( "" != video_id )
			gosub, Stage1_VideoID2PM
	} else if ( "从剪贴板获取视频ID(&V)" = A_ThisMenuItem ) {
		gosub, ClipURL2VID
	} else if ( "从FireFox获取视频ID(&F)" = A_ThisMenuItem ) {
		gosub, copyURL2Clip
	} else if ( "xxxxxx" = A_ThisMenuItem ) {
	}
return

GuiClose:
GuiEscape:
	ExitApp
return

^esc::reload
+esc::Edit
!esc::ExitApp
/*
CopyInfo2Clip(Num=1) {
	LV_GetText(NowVar, LV_GetNext(0), Num)
	Clipboard = %NowVar%
	TrayTip, 剪贴板:, %NowVar%
}
*/

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



