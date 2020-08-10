; 用途: 萌萌哒 @ 2020-05-08
#NoEnv
	verDate := "2020-08-10"

	bDebug := false
	bDeleteFile := false ; 删除临时文件

	AddStr := ""
	UAStr := "sifwjefl"

	wDir := General_getWDir() ; T:\, A_WorkingDir

	TOCURL  := "https://www.yy.com/u/videos/3/4020793/1/30"
	TOCURL2 := "https://www.yy.com/u/videos/3/4020793/2/30"
	; https://www.yy.com/u/videos/%ViedeoType%/%UserID%/%PageNO%/%PageSize%
	
	gosub, MenuInit
	gosub, GuiInit

	gosub, getURLFromTOC

	TrayTip, 热键:, F1: TS -> MP4`nCtrl + F1: TS -> M4A`nwDir: %wDir%
return



GuiInit:
	Gui, Add, ListView, x2 y10 w940 h350 vFoxLV gClickLV, NO.|Time|Title|Duration|M3U8
		LV_ModifyCol(1, 30), LV_ModifyCol(2, 50), LV_ModifyCol(3, 200), LV_ModifyCol(4, 70), LV_ModifyCol(5, 540)
	Gui, Add, Edit, x2 y370 w940 h80 vTSURL, AAA`nBBB`nCCC`nDDD`nEEE`n
	; Generated using SmartGUI Creator 4.0
	Gui, Show, w950 h455, YY Helper Ver: %verDate%
Return

ClickLV: ; 点击LV
	nRow := A_EventInfo
	if ( A_GuiEvent = "DoubleClick" ) {
		LV_GetText(M3U8URL, nRow, 5)
		gosub, getURLfromM3U8
	}
return

MenuInit:
	Menu, MyMenuBar, Add, 馒头2, MenuAct
	Menu, MyMenuBar, Add, 　　　　　　　　　　, MenuAct
	Menu, MyMenuBar, Add, 限速字符串(&L), MenuAct
	Menu, MyMenuBar, Add, 　　　　　　　　　　　, MenuAct
	Menu, MyMenuBar, Add, 创建文件夹:昨天(&Y), MenuAct
	Menu, MyMenuBar, Add, 　　　　　　　　　　　　, MenuAct
	Menu, MyMenuBar, Add, 复制Edit内容(&C), MenuAct
	Gui, Menu, MyMenuBar
return

MenuAct:
	if ( "馒头2" = A_ThisMenuItem ) {
		TOCURL := TOCURL2
		gosub, getURLFromTOC
	} else if ( "创建文件夹:昨天(&Y)" = A_ThisMenuItem ) {
		YesterDay += -1, D
		FormatTime, yystd, %YesterDay%, yyyy-MM-dd_Y
		wDir .= "\" . yystd
		FileCreateDir, %wDir%
		TrayTip, 工作目录:, %wDir%
	} else if ( "限速字符串(&L)" = A_ThisMenuItem ) {
		AddStr := "--limit-rate=600k"
		Traytip, 提示:, 字符串: %AddStr%
	} else if ( "复制Edit内容(&C)" = A_ThisMenuItem ) {
		GuiControlGet, TSURL
		Clipboard := TSURL
		Traytip, 剪贴板:, %TSURL%
	}
return

GuiClose:
GuiEscape:
	ExitApp
return

TS2m4a:
	clipboard =
	send ^c
	ClipWait
	iPath := clipboard

	SplitPath, iPath, , , , tsNameNoExt, OutDrive

	run, ffmpeg.exe -i "%iPath%" -vn -acodec copy %tsNameNoExt%.m4a, %wDir% ; * -> m4a
return

TS2mp4:
	clipboard =
	send ^c
	ClipWait
	iPath := clipboard

	SplitPath, iPath, , , , tsNameNoExt, OutDrive

	run, ffmpeg.exe -i "%iPath%" -vcodec copy -acodec copy -movflags faststart %tsNameNoExt%.mp4, %wDir% ; * -> mp4
return

^esc::reload
+esc::Edit
!esc::ExitApp
F1:: gosub TS2mp4
^F1:: gosub TS2m4a

getURLFromTOC:
	if ( bDebug ) { ; debug
		jsonName := "1.json"
	} else {
		jsonName := "YY_Idx_" . A_MM . "-" . A_DD . ".json"
		IfNotExist, %wDir%\%jsonName%
			runwait, wget -O %jsonName% -U %UAStr% %TOCURL%, %wDir%, min
	}

	FileRead, sJSON, *P65001 %wDir%\%jsonName%
	if ( bDeleteFile )
		FileDelete, %wDir%\%jsonName%

	if ( "" = sJSON ) {
		Traytip, 下载错误:, %TOCURL%
		return
	}

	j := JSON.parse(sJSON)

	for i, v in j.videoPage.result {
		LV_Add("", i, v.beforeTime, v.title, v.duration, v.resUrl) ; NO.|Time|Title|Duration|M3U8
;		msgbox, % i "`n" v.beforeTime "`n"  v.duration "`n" v.resUrl "`n" v.title
	}
	LV_Add()
return

#Include <JSON_Class>

getURLfromM3U8:
;	msgbox, % M3U8URL

	url_1 := ""
	RegExMatch(M3U8URL, "Ui)_([0-9]{13})\.m3u8", url_)
	m3u8Name := A_now . "_" . url_1 . ".m3u8"
	runwait, wget -O %m3u8Name% -U %UAStr% %M3U8URL%, %wDir%, min
	FileRead, mList, *P65001 %wDir%\%m3u8Name%
	if ( bDeleteFile )
		FileDelete, %wDir%\%m3u8Name%

/*
	clipboard =
	send ^c
	ClipWait
	FileRead, mList, %clipboard%
*/

	oStr := ""
	bTSstart := true
	TSStartURL := ""
	TSLastURL := ""
	TSID := ""

	loop, parse, mList, `n, `r
	{
		if ( ! InStr(A_LoopField, "http") )
			continue
		SplitPath, A_LoopField, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
; msgbox, % A_LoopField "`n`n" OutFileName "`n" OutDir "`n" OutExtension "`n" OutNameNoExt "`n" OutDrive
		if ( TSID != OutNameNoExt ) {
			bTSstart := true
			if ( "" != TSStartURL ) {
				oStr .= "wget -c " . AddStr . " """ . getStoE(TSStartURL, TSLastURL) """`n"
; msgbox, % getStoE(TSStartURL, TSLastURL) "`n`n" TSStartURL "`n" TSLastURL
			}
		}
		if ( bTSstart ) {
			TSID := OutNameNoExt
			TSStartURL := A_LoopField
			bTSstart := false
		} else {
			TSLastURL := A_LoopField
		}
	}
	if ( "" != TSStartURL ) {
		oStr .= "wget -c " . AddStr . " """ . getStoE(TSStartURL, TSLastURL) """`n`n"
	}
	FileAppend, %oStr%, %wDir%\yy.bat
	GuiControl, text, TSURL, %oStr%
return

getStoE(StartURL, LastURL) {
	SplitPath, StartURL, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	if ( InStr(StartURL, "s=0&e=") ) {
		return OutDir . "/" . OutNameNoExt . ".ts"
	}
	RegExMatch(StartURL, "Ui)s=([0-9]+)&e=([0-9]+)&", ss_)
	RegExMatch(LastURL, "Ui)s=([0-9]+)&e=([0-9]+)&", ll_)
;	msgbox, % StartURL "`n" ss_1 "`n" ss_2 "`n`n" LastURL "`n" ll_1 "`n" ll_2
	return OutDir . "/" . OutNameNoExt . ".ts?s=" . ss_1 . "&e=" . ll_2
}

; http://yycloudlive15013.bs2dl.yy.com/crs_9217249dba8f4170ada27e97a9be7024.ts?s=0&e=414727&r=800x600&tc=0&ts=1588863087
; http://yycloudlive15013.bs2dl.yy.com/crs_9217249dba8f4170ada27e97a9be7024.ts?s=414728&e=744855&r=800x600&tc=0&ts=1588863089

TS_Copy(TSPath, tPath, sPos=0, ePos=666, BufSize=4096) {  ; 从完整的ts中根据 s=0&e=414727 分割为新的ts
	ss := sPos + 0
	ee := ePos + 1

	if ( ee - ss > BufSize ) {
		BufSize := 4096
	}

	VarSetCapacity(buf, BufSize)
	sFile := FileOpen(TSPath, "r")
	tFile := FileOpen(tPath, "w")

	rPos := ss
	sFile.Seek(rPos)
	loop {
		nowCount := ee - rPos
		if ( nowCount > BufSize ) {
			nowCount := BufSize
		} else if ( nowCount < 1 ) {
			break
		}

		lenRead  := sFile.RawRead(&buf, nowCount)
		lenWrite := tFile.RawWrite(&buf, lenRead)

		rPos += lenWrite
		if ( lenRead != lenWrite )
			msgbox, % "Error Pos: " rPos "`n"  lenRead "`n" lenWrite
	}

	tFile.Close()
	sFile.Close()
}

