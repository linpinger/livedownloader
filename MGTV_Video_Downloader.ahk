; 用途: 萌萌哒 @ 2020-08-03
; 用法: 复制m3u8链接，按F1
/*

https://www.mgtv.com/b/337284/8634094.html

*/
	Arg1 = %1%

	wDir := General_getWDir() . "\" . A_MM . A_Sec . "." . A_MSec ; T:\, A_WorkingDir

	refURL  := "https://www.mgtv.com/"

	if ( "GUI" = Arg1 ) {
		InputBox, M3U8URL, URL, 输入M3U8 URL, , , , , , , , %Clipboard%
		gosub, DoDo
		ExitApp
	}

^esc::reload
+esc::Edit
!esc::ExitApp
F1:: gosub, ClipURL2M3U8

ClipURL2M3U8:
	IfWinExist, ahk_class MozillaWindowClass
	{
		WinActivate, ahk_class MozillaWindowClass
		WinWaitActive, ahk_class MozillaWindowClass
		Clipboard =
		send {Rbutton}
		sleep 500
		send cu
		ClipWait

		M3U8URL := Clipboard
		gosub, DoDo
	}
return

DoDo: ; M3U8URL
	if ( ! InStr(M3U8URL, ".m3u8") ) {
		TrayTip, 错误:, 不包含.m3u8地址
		sleep 2000
		return
	}

	; 分析得到两地址
	ff_1 := "", ff_2 := ""
	RegExMatch(M3U8URL, "smi)((http[^\?]+/)[^/\.]+\.m3u8?[^""]+)", ff_) ; url, dir
	M3U8_URL := FF_1
	BaseURL := FF_2

	FileCreateDir, %wDir%
	M3U8_Name := "00_" . A_now . ".m3u8"
	runwait, wget -O %M3U8_Name% --referer=%refURL% "%M3U8_URL%", %wDir%, min
	FileRead, mm, %wDir%\%M3U8_Name%
	if ( ! InStr(mm, "#EXT-X-ENDLIST") ) {
		traytip, 错误:, m3u8内容不正确
		return
	}

	gosub, ts2bat
return

ts2bat:
;	BaseURL := ""
;	FileRead, mm, T:\00\00.m3u8
	oStr := ""
	count := 1000
	loop, parse, mm, `n, `r
	{
		if ( ! InStr(A_LoopField, "mp4.ts") )
			continue
		++ count
		oStr .= "wget -c -t 3 -T 9 --referer=" . refURL . " -O " . count . ".ts """ . BaseURL . A_LoopField . """`n"
	}
	FileAppend, %oStr%, %wDir%\00.bat
	traytip, ok:, %wDir%\00.bat
return

; wget --referer=https://www.mgtv.com/ -O 000.ts "url"
; cat *.ts > ..\00.ts
; ts -> mp4

General_getWDir() { ; 如果存在内存盘，就返回它，否则为工作目录
	DriveGet, DriveStr, List
	if InStr(DriveStr, "T")
		return "T:\"
	else
		return A_WorkingDir
}
