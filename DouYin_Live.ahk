;	用途: 萌萌哒 @ 2020-07-28

	wDir := General_getWDir() ; T:\, A_WorkingDir

	bDebug := false

dyList=
(join| C
; upName:upID:roomID
qingNong: :
chenJia: :
qingNong:94151739290:6844506240375065352
chenJia:110218977144:6844488459978672903
new: :
)

GuiInit:
	Gui, Add, ComboBox, x10 y10 w285 h20 simple R7 choose1 gChangeUP vUPStr, %dyList%
	Gui, Add, Edit, x300 y10 w80  h20 vUPName, name
	Gui, Add, Edit, x380 y10 w110 h20 vUPID, upID
	Gui, Add, Edit, x490 y10 w130 h20 vRoomID, roomID
	Gui,Add,Button,x630 y0 w159 h33 gMyFunc, 循环下载(&F)

	Gui, Add, Button, x300 y30 w129 h33 gclip2ShareURL, ShareURL
	Gui, Add, Edit, x430 y40 w364 h20 vshareURL

	Gui, Add, Button, x300 y70 w129 h53 gdoJsonURL, jsonURL
	Gui, Add, Edit, x430 y70 w364 h50 vjsonURL

	Gui, Add, Button, x300 y130 w129 h33 vDoFlvURL gDoFlvURL, flvURL(&S)
	Gui, Add, Edit, x430 y130 w364 h30 vflvURL

	Gui, Add, ComboBox, x10 y130 w165 h20 R10 choose1 vWDir gChageSaveDir, %wDir%|%A_WorkingDir%|T:\|D:\tmp
	Gui, Add, Button, x180 y130 w109 h33 gDownFLV, 下载FLV(&D)

	Gui, Show, w800 h170 y69, DY

	gosub, ChangeUP

	GuiControl, Focus, DoFlvURL
Return

MyFunc:
	Gui, submit, nohide

templateStr=
(join`n

	HeadName := "%upName%"
	flvURL := "%flvURL%"
	wDir := "%wDir%"

	loop 50 {
		runwait, wget -O `%HeadName`%_`%A_now`%_DouYin.flv "`%flvURL`%", `%wdir`%, min UseErrorLevel
		if ( ErrorLevel != 0 )
			sleep 9000
	}

cleanBlankFLV: ; 删除所有空flv
	loop, `%wDir`%\*.flv, 0, 0
	{
		FileGetSize, nowSize, `%A_LoopFileFullPath`%
		if ( 0 = nowSize )
			FileDelete, `%A_LoopFileFullPath`%
	}
return

)
	FileAppend, %templateStr%, %wDir%\%UPName%_DouYin_Loop50.ahk
	run, %wDir%\%UPName%_DouYin_Loop50.ahk
return

ChangeUP:
	GuiControlGet, UPStr
	FF_1 := "", FF_2 := "", FF_3 := ""
	StringSplit, FF_, UPStr, :, %A_Space%
	GuiControl, text, UPName, %FF_1%
	GuiControl, text, UPID, %FF_2%
	GuiControl, text, RoomID, %FF_3%
	if ( FF_3 != "")
		GuiControl, text, shareURL, % roomID2ShareURL(FF_3)
	else
		GuiControl, text, shareURL
	if ( FF_3 != "" and FF_2 != "" )
		GuiControl, text, jsonURL, % roomID2JsonURL(FF_3, FF_2)
	else
		GuiControl, text, jsonURL
return

ChageSaveDir:
	GuiControlGet, WDir
return

clip2ShareURL: ; 按钮: shareURL
	If ( InStr(Clipboard, "https://v.douyin.com/") ) {
		FF_1 := ""
		RegExMatch(Clipboard, "smUi)(https://v.douyin.com/[^/]+[/])", FF_)
		GuiControl, text, shareURL, %FF_1%
	}
	If ( InStr(Clipboard, "https://www.iesdouyin.com/share/live/") ) {
		FF_1 := ""
		RegExMatch(Clipboard, "smi)(https://www.iesdouyin.com/share/live/[0-9]+)", FF_)
			XX_1 := ""
			RegExMatch(FF_1, "smi)/live/([0-9]+)", XX_)
		GuiControl, text, shareURL, %FF_1%
		GuiControl, text, RoomID, %XX_1%
	}
; https://webcast.amemv.com/webcast/reflow/6854151890994039560?u_code=150cihdlf&utm_source=copy&utm_campaign=client_share&utm_medium=android&share_app_name=douyin
	If ( InStr(Clipboard, "https://webcast.amemv.com/webcast/reflow/") ) {
		FF_1 := ""
		RegExMatch(clipboard, "smi)(http[0-9a-zA-Z/:_\.\?&=]*)", FF_)
		GuiControl, text, shareURL, %FF_1%
	}
return

doJsonURL: ; 按钮: jsonURL
	GuiControlGet, shareURL
	jsonURL := shareURL2JsonURL(shareURL)
	if ( InStr(jsonURL, ".flv") ) { ; 2020-07-10: 直接包含flv地址
		flvURL := jsonURL
		GuiControl, text, flvURL, %flvURL%
		return
	}
	GuiControl, text, jsonURL, %jsonURL%
	FF_1 := "", FF_2 := ""
;	jsonURL  := "https://webcast-hl.amemv.com/webcast/room/reflow/info/?room_id=6844506240375065352&type_id=0&user_id=94151739290&live_id=1&app_id=1128"
	RegExMatch(jsonURL, "i)room_id=([0-9]+).*user_id=([0-9]+)", FF_)
	GuiControl, text, RoomID, %FF_1%
	GuiControl, text, upID, %FF_2%

	GuiControlGet, upName
	oStr := upName . ":" . FF_2 . ":" . FF_1
	clipboard = %oStr%
	TrayTip, 剪贴板:, %oStr%
return

DoFlvURL: ; 按钮: flvURL
	GuiControlGet, jsonURL
	flvURL := jsonURL2flvURL(jsonURL)
	GuiControl, text, flvURL, %flvURL%
	clipboard = %flvURL%
	TrayTip, 剪贴板:, %flvURL%
return

DownFLV:
	Gui, submit, NoHide
	run, wget -O %upName%_%A_Now%_DouYin.flv "%flvURL%", %wDir% ; Clipboard := "wget -O " . upName . "_" . A_Now . "_DouYin.flv """ . flvURL . """"
return

GuiClose:
GuiEscape:
	ExitApp
return

^esc::reload
+esc::Edit
!esc::ExitApp


roomID2ShareURL(roomID) {
	return "https://www.iesdouyin.com/share/live/" . roomID
}

roomID2JsonURL(roomID, userID=1111) {
	return "https://webcast-hl.amemv.com/webcast/room/reflow/info/?room_id=" . roomID . "&type_id=0&user_id=" . userID . "&live_id=1&app_id=1128"
}

shareURL2JsonURL(iURL="https://www.iesdouyin.com/share/live/6844488459978672903") { ; or like "https://v.douyin.com/JL5mCkq/"
	global wDir, bDebug
	IfNotExist, %wDir%\DouYin_XX.html
		runwait, wget -U Mobile -O DouYin_XX.html "%iURL%", %wDir%, min
	FileRead, suu, *P65001 %wDir%\DouYin_XX.html
	if ! bDebug
		FileDelete, %wDir%\DouYin_XX.html

	if ( InStr(suu, ".flv") ) { ; 2020-07-10: 网页直接包含flv地址
		RegExMatch(suu, "smUi)""(http[^""]*\.flv)""", FF_)
		return FF_1
	}

;	ff_1 := "", ff_2 := ""
	RegExMatch(suu, "smUi)var roomId = ""([0-9]+)"".*uid: ""([0-9]+)""", FF_)
	return roomID2JsonURL(FF_1, FF_2)
}

jsonURL2flvURL(iURL="https://webcast-hl.amemv.com/webcast/room/reflow/info/?room_id=6844488459978672903&type_id=0&user_id=110218977144&live_id=1&app_id=1128") {
	global wDir, bDebug
	IfNotExist, %wDir%\DouYin_XX.json
		runwait, wget -U Mobile -O DouYin_XX.json "%iURL%", %wDir%, min
	FileRead, suu, *P65001 %wDir%\DouYin_XX.json
	if ! bDebug
		FileDelete, %wDir%\DouYin_XX.json
	
	; data.room.stream_url.rtmp_pull_url
	; data.room.status : 4:off, 2:on, 3:可能是暂时离开     或者 包含 own_room (且room_ids与room_id相等) 表示在线

	RegExMatch(suu, "smUi)""rtmp_pull_url"":""([^""]+)""", FF_)
	if ( InStr(suu, "own_room") ) {
		RegExMatch(iURL, "Ui)room_id=([0-9]+)&", UU_)
		if ( InStr(suu, """room_ids"":[" . UU_1 . "]") ) { ; roomID要相等才表示在线？
			return, FF_1
		} else {
			return, FF_1 .  "?statu=offline2"
		}
	} else {
		return, FF_1 .  "?statu=offline"
	}
}

/*

https://s3.pstatp.com/ies/resource/falcon/douyin_falcon/page/reflow_live/index_d691f61.js
"User-Agent: Mozilla/5.0 (Linux; Android 7.0; SM-G892A Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/67.0.3396.87 Mobile Safari/537.36"

# qingNong
- upName := "qingNong", upID := "94151739290",  roomID := "6844506240375065352"
- "https://www.iesdouyin.com/share/live/6844506240375065352"
- "https://webcast-hl.amemv.com/webcast/room/reflow/info/?room_id=6844506240375065352&type_id=0&user_id=94151739290&live_id=1&app_id=1128"
- "http://pull-flv-l1.douyincdn.com/stage/stream-106945123289923614_or4.flv"

# chenJia
- upName := "chenJia",  upID := "110218977144", roomID := "6844488459978672903"
- "https://www.iesdouyin.com/share/live/6844488459978672903"
- "https://webcast-hl.amemv.com/webcast/room/reflow/info/?room_id=6844488459978672903&type_id=0&user_id=110218977144&live_id=1&app_id=1128"
- "http://pull-flv-l1.douyincdn.com/stage/stream-106945123289923614_or4.flv"

# 2020-07-10
https://v.douyin.com/JN4hahP/
- 直接重定向: ->
https://webcast.amemv.com/webcast/reflow/6847473349451320072?u_code=150cihdlf&utm_source=copy&utm_campaign=client_share&utm_medium=android&share_app_name=douyin
- html中包含json，里面有flv地址:
http://pull-l3.douyincdn.com/stage/stream-106991766096838738.flv

- 检测在线状态API:
https://webcast.amemv.com/webcast/room/ping/audience/?room_id=6847657250236926723&only_status=1&aid=1128

*/
