#Persistent
;	HeadName := "tsx"
;	RoomID := "1188629"
	HeadName := "xxxxxxx"
	RoomID   := "nnnnnnn"

	statuURL := "http://api.live.bilibili.com/room/v1/Room/room_init?id=" . RoomID
	roomURL := "http://api.live.bilibili.com/room/v1/Room/playUrl?cid=" . RoomID . "&quality=4&platform=web"

	CoordMode, tooltip, Screen

	wDir := A_WorkingDir

	SetTimer, getStatu, 55000
	gosub, getStatu
return

getStatu:
	statuJson := getJson(statuURL) ; 检测是否在线
	if ( ! InStr(statuJson, """live_status"":1,") ) { ; 不在线
		tooltip, %A_Min%m:%A_Sec%s, % A_ScreenWidth / 2 + 100 , 50
		return
	}

	json := getJson(roomURL)
	
	RegExMatch(json, "smUi)""(http[^""]*)""", uu_)  ; 获取第一个地址
;	RegExMatch(json, "smUi)""(http[^""]*acgvideo.com[^""]*)""", uu_) ; 获取非bilivideo.com

	flvURL := uu_1, uu_1 := ""
	StringReplace, flvURL, flvURL, \u0026, &, A
	
	TrayTip, %HeadName%已上线:, %A_Hour%:%A_Min%:%A_Sec%

	flvName := HeadName . "_" . A_now . ".flv"
FileAppend, wget -O %flvName% "%flvURL%"`n`n, %wDir%\bilibili_live.log

	Menu, Tray, Tip, 下载: %flvName%
	tooltip, , % A_ScreenWidth / 2 + 100 , 50
	SetTimer, getStatu, Off

;	run, mpv --no-ytdl --http-header-fields="referer: https://live.bilibili.com/" "%flvURL%"
	runwait, wget --referer="https://live.bilibili.com/" -U "Mozilla/5.0 (iPhone`; U`; CPU iPhone OS 4_1 like Mac OS X`; en-us) AppleWebKit/532.9 (KHTML`, like Gecko) Mobile/8B117" -t 1 -T 9 -O %flvName% "%flvURL%", %wDir%, min  ; 下载FLV

	gosub, cleanBlankFLV

	SetTimer, getStatu, On
	gosub, getStatu
return


cleanBlankFLV: ; 删除所有空flv
	loop, %wDir%\*.flv, 0, 0
	{
		FileGetSize, nowSize, %A_LoopFileFullPath%
		if ( 0 = nowSize )
			FileDelete, %A_LoopFileFullPath%
	}
return

getJson(jsonURL) {
	global wDir

	sSavePath := wDir . "\Wget_" . A_now . ".json"
	runwait, wget -O "%sSavePath%" "%jsonURL%", , hide
	FileRead, jsonStr, *P65001 %sSavePath%
	FileDelete, %sSavePath%

	return, jsonStr
}

