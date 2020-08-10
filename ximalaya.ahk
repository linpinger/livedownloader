; ��;: ������ @ 2020-08-06
	verDate := "2020-08-10"

	bDebug := false
	wDir := General_getWDir() ; T:\, A_WorkingDir
	SetWorkingDir, %wDir%

	if ( bDebug ) {
		runWinStat := "min"
	} else {
		runWinStat := "hide"
	}

	NowAlbumURL := "https://www.ximalaya.com/renwen/3623979/"

	; ѡ��
	bAutoDownAllIDX := false ; �Զ�����ȫ���б�
	bAppendDownLink := true  ; ������������������

	gosub, MenuInit
	gosub, GuiInit
return

GuiInit:
	Gui, Add, GroupBox, x12 y10 w790 h50 cBlue vGrpBox, ��ַ|��ǰҳ��|Cookie
	Gui, Add, Edit, x22 y30 w450 h20 vNowAlbumURL, %NowAlbumURL%
	Gui, Add, Edit, x482 y30 w30 h20 vPageNum, 0
	Gui, Add, Text, x512 y33 w10 h20 cBlue, /
	Gui, Add, Edit, x522 y30 w30 h20 +ReadOnly vPageCount, 0
	Gui, Add, Text, x552 y33 w20 h20 cBlue, ҳ
	Gui, Add, Edit, x572 y30 w220 h20 vCookieStr

	Gui, Add, ListView, x12 y70 w790 h360 vFoxLV gClickLV, No|TrackID|Title|Sec|Date|VIP_Statu
		LV_ModifyCol(1, 50), LV_ModifyCol(2, 100), LV_ModifyCol(3, 360), LV_ModifyCol(4, 40), LV_ModifyCol(5, 80), LV_ModifyCol(6, 100)
;			LV_Add("", v.index, v.trackId, v.title, v.duration, v.createDateFormat, v.isVipFirst)

	Gui, Add, StatusBar, gClickStatusBar, �÷���ճ��ר����ַȻ��س������˵���һҳ��˫����Ŀ���ػ����˵���������
	Gui, Show, w810 h460, Ximalaya DownLoader Ver: %verDate%
	onmessage(0x100, "FoxInput")  ; ������ؼ��������ⰴ���ķ�Ӧ
Return


FoxInput(wParam, lParam, msg, hwnd)  ; ������ؼ��������ⰴ���ķ�Ӧ
{ ;	tooltip, <%wParam%>`n<%lParam%>`n<%msg%>`n<%hwnd%>`n%A_GuiControl%
	Global
	If ( A_GuiControl = "NowAlbumURL" and wParam = 13 ) {
		gosub, GetIDX
	} else If ( A_GuiControl = "PageNum" and wParam = 13 ) {
		gosub, GetIDX
	} else If ( A_GuiControl = "FoxLV" and wParam = 13 ) {
		nRow := LV_GetNext()

		LV_GetText(nowIDX, nRow, 1)
		LV_GetText(nowTrackID, nRow, 2)
		LV_GetText(nowTitle, nRow, 3)

		gosub, DownOne
	}
}


ClickLV: ; ���LV
	nRow := A_EventInfo
	if ( A_GuiEvent = "DoubleClick" ) {
		LV_GetText(nowIDX, nRow, 1)
		LV_GetText(nowTrackID, nRow, 2)
		LV_GetText(nowTitle, nRow, 3)

		gosub, DownOne
	}
return

DownOne:
	if ( "" = nowIDX or "No" = nowIDX )
		return

		m4aURL := GetAudioInfo(nowTrackID, CookieStr)
		if ( InStr(m4aURL, "notBuy@") ) {
			StringReplace, m4aURL, m4aURL, notBuy@, , A
			msgbox, δ����Ӧ��ֻ�����ز���
		}

		if ( "" = m4aURL ) {
			ai := GetVipAudioInfo(nowTrackID, CookieStr)
			m4aURL := ai.URL
			albumId := ai.albumId
		}

; Clipboard := m4aURL
		GuiControlGet, cookieStr
		if ( "" != cookieStr ) {
			AddArg := "--header=""Cookie: " . cookieStr . """"
		}

		if ( "" != albumId )
			FileCreateDir, %A_WorkingDir%\%albumId%
		AudExt := ".m4a"
		if ( InStr( m4aURL, ".mp3") )
			AudExt := ".mp3"
		saveName  := nowIDX . "_" . nowTrackID . AudExt
		saveName2 :=  nowIDX . "_" . nowTrackID . "_" . purePath(nowTitle) . AudExt
SB_SetText("��������: " nowIDX " / " trackCounts  " -> " saveName2)
		runwait, wget -t 5 -T 9 -c -O %saveName% "%m4aURL%" %AddArg%, %A_WorkingDir%\%albumId%, %runWinStat%
		FileMove, %A_WorkingDir%\%albumId%\%saveName%, %A_WorkingDir%\%albumId%\%saveName2%
		if ( bAppendDownLink )
			FileAppend, wget -t 5 -T 9 -c -O %saveName2% "%m4aURL%" %AddArg%`n, %A_WorkingDir%\%albumId%\00_Down.bat
SB_SetText("�������: " nowIDX " / " trackCounts " -> " saveName2)
return

ClickStatusBar:
	if ( A_GuiEvent = "DoubleClick" ) {
		run, %A_WorkingDir%\%albumId%
	}
return


batDown:
	nRow := LV_GetNext(0)
Loop % LV_GetCount()
{
	if ( A_index < nRow )
		continue
	if ( bStopDownload )
		break
	
	LV_GetText(nowIDX, nRow, 1)
	LV_GetText(nowTrackID, nRow, 2)
	LV_GetText(nowTitle, nRow, 3)

	gosub, DownOne

	++nRow
	LV_Modify(nRow, "Vis focus")
}
	
return

MenuInit:
	Menu, OMenu, Add, �Զ�����ȫ���б�(&A), MenuAct
	if ( bAutoDownAllIDX )
		Menu, OMenu, Check, �Զ�����ȫ���б�(&A)
	Menu, OMenu, Add, ������������������(&B), MenuAct
	if ( bAppendDownLink )
		Menu, OMenu, Check, ������������������(&B)
	Menu, OMenu, Add, ����ģʽ(&D), MenuAct
	if ( bDebug )
		Menu, OMenu, Check, ����ģʽ(&D)

	Menu, MyMenuBar, Add, ѡ��(&O), :OMenu

	Menu, MyMenuBar, Add, ����, MenuAct
	Menu, MyMenuBar, Add, ����б�(&C), MenuAct
	Menu, MyMenuBar, Add, �Ӽ�����ճ����ַ(&V), MenuAct
	Menu, MyMenuBar, Add, ����������, MenuAct
	Menu, MyMenuBar, Add, ��һҳ(&S), MenuAct
	Menu, MyMenuBar, Add, ������, MenuAct
	Menu, MyMenuBar, Add, ��ѡ�е��п�ʼ��������(&P), MenuAct
	Menu, MyMenuBar, Add, ֹͣ(&T), MenuAct
	Gui, Menu, MyMenuBar
return

MenuAct:
	if ( "��һҳ(&S)" = A_ThisMenuItem ) {
		gosub, GetIDX
	} else if ( "�Զ�����ȫ���б�(&A)" = A_ThisMenuItem ) {
		Menu, OMenu, ToggleCheck, �Զ�����ȫ���б�(&A)
		bAutoDownAllIDX := ! bAutoDownAllIDX
	} else if ( "������������������(&B)" = A_ThisMenuItem ) {
		Menu, OMenu, ToggleCheck, ������������������(&B)
		bAppendDownLink := ! bAppendDownLink
	} else if ( "����ģʽ(&D)" = A_ThisMenuItem ) {
		Menu, OMenu, ToggleCheck, ����ģʽ(&D)
		bDebug := ! bDebug
		if ( bDebug ) {
			runWinStat := "min"
		} else {
			runWinStat := "hide"
		}
	} else if ( "����б�(&C)" = A_ThisMenuItem ) {
		LV_Delete()
	} else if ( "�Ӽ�����ճ����ַ(&V)" = A_ThisMenuItem ) {
		if ( InStr(Clipboard, ".ximalaya.com") ) {
			GuiControl, text, NowAlbumURL, %Clipboard%
			GuiControl, text, PageNum, 0
			GuiControl, text, PageCount, 0
		}
	} else if ( "��ѡ�е��п�ʼ��������(&P)" = A_ThisMenuItem ) {
		bStopDownload := false
		gosub, batDown
	} else if ( "ֹͣ(&T)" = A_ThisMenuItem ) {
		bStopDownload := true
	} else if ( "xxxxx" = A_ThisMenuItem ) {
	}
return


GuiClose:
GuiEscape:
	ExitApp
return


^esc::reload
+esc::Edit
!esc::ExitApp
; F1:: LV_Modify(30, "Vis focus select")

GetIDX:
	Gui, Submit, NoHide

	++PageNum
	GuiControl, text, PageNum, %PageNum%
;	NowAlbumURL := "https://www.ximalaya.com/youshengshu/18372779/"
;	PageNum := 1

	; https://www.ximalaya.com/revision/album/v1/getTracksList?albumId=18372779&pageNum=3
	if ( InStr(NowAlbumURL, ".ximalaya.com/") ) {
		abid_1 := ""
		if ( InStr(NowAlbumURL, "/youshengshu/") ) {
			RegExMatch(NowAlbumURL, "i).ximalaya.com/youshengshu/([0-9]+)", abid_)
		} else {
			RegExMatch(NowAlbumURL, "i).ximalaya.com/[0-9a-z]+/([0-9]+)", abid_)
		}
		if ( abid_1 = "" ) {
			msgbox, ��ַ�����Ϲ���: www.ximalaya.com/xxxxxxxx/1234567/`n`n%NowAlbumURL%
			return
		}

		albumId := abid_1 ; ��������m4a��ʱ����Ҫ
		if ( "" != cookieStr ) {
			AddArg := "--header=""Cookie: " . cookieStr . """"
		}

		jsonURL := "https://www.ximalaya.com/revision/album/v1/getTracksList?albumId=" . albumId . "&pageNum=" . PageNum
		jsonName := "xmly_album_" . albumId . "_page_" . PageNum . ".json"
		IfNotExist, %jsonName%
			runwait, wget -t 3 -T 5 -O %jsonName% "%jsonURL%" %AddArg%, , %runWinStat%
		FileRead, jsonStr, *P65001 %jsonName%
		if ( ! bDebug )
			FileDelete, %jsonName%

		j := JSON.parse(jsonStr)
		trackCounts := j.data.trackTotalCount ; ���ж�����Ƶ
		pagePerTrack := j.data.pageSize  ; ÿҳ����
		PageCount := ceil(trackCounts / pagePerTrack) ; ҳ��
		GuiControl, text, PageCount, %PageCount%

		GuiControl, text, GrpBox, ��ַ|��ǰҳ��|Cookie    ��ǰ: %PageNum% / %PageCount% ҳ���� %trackCounts% ��Ƶ��ÿҳ %pagePerTrack% ��Ƶ

		; index, trackId, title, duration, isVipFirst
		for i, v in j.data.tracks
			LV_Add("", v.index, v.trackId, v.title, v.duration, v.createDateFormat, v.tag " " v.priceOp)
		LV_Add("", "", "-----", "����Ϊ�� " . PageNum . " ҳ����")
		LV_Modify(LV_GetCount(), "Vis focus")
	}

	if ( bAutoDownAllIDX ) { ; �Զ�����ʣ��ҳ��
		if ( PageNum + 1 > PageCount ) {
			return
		} else {
			gosub, GetIDX
		}
	}
return

#Include <JSON_Class>

purePath(iName) {
	StringReplace, iName, iName, :, ��, A
	StringReplace, iName, iName, /, ��, A
	StringReplace, iName, iName, \, ��, A
	StringReplace, iName, iName, |, ��, A
	StringReplace, iName, iName, `,, ��, A
	StringReplace, iName, iName, >, ��, A
	StringReplace, iName, iName, <, ��, A
	StringReplace, iName, iName, *, ��, A
	StringReplace, iName, iName, ?, ��, A
	return iName
}

GetAudioInfo(nowTrackID, CookieStr="") {
	global bDebug, runWinStat
	if ( "" != cookieStr ) {
		AddArg := "--header=""Cookie: " . cookieStr . """"
	}
	url := "https://www.ximalaya.com/revision/play/v1/audio?id=" . nowTrackID . "&ptype=1"
	fname := "audio.info_" . nowTrackID . ".json"
	IfNotExist, %fname%
		runwait, wget -t 3 -T 5 -O %fname% -U "ting_6.3.60(sdk`,Android16)" "%url%" %AddArg%, , %runWinStat%
	FileRead, jsonStr, *P65001 %fname%
	if ( ! bDebug )
		FileDelete, %fname%

	j := JSON.parse(jsonStr)
	if ( j.data.hasBuy )
		return j.data.src
	else
		return "notBuy@" . j.data.src
}
GetVipAudioInfo(trackId, cookieStr="") {
	global bDebug, runWinStat
	if ( "" != cookieStr ) {
		AddArg := "--header=""Cookie: " . cookieStr . """"
	}
	ts := getUnixTime(A_now)
	url := "https://mpay.ximalaya.com/mobile/track/pay/" . trackId . "/" . ts . "?device=pc&isBackend=true&_=" . ts
	fname := "vip.info_" . trackId . ".json"

	IfNotExist, %fname%
		runwait, wget -t 3 -T 5 -O %fname% -U "ting_6.3.60(sdk`,Android16)" "%url%" %AddArg%, ,%runWinStat% 
	FileRead, jsonStr, *P65001 %fname%
	if ( ! bDebug )
		FileDelete, %fname%

	j := JSON.parse(jsonStr)

	fileName := DecryptFileName(j.seed, j.fileId)
;	msgbox, % fileName

	s2 := DecryptUrlParams(j.ep)
	ss := StrSplit(s2, "-") ; fe4f133ccbf4b22dfa2a1e704ccbbda8-095a40a29f9548ca12574a0cf223338d-2270-1596778089

	buyKey := ss[1] ; �� j.buyKey ��ͬ
	sign := ss[2]
	token := ss[3]
	timestamp := ss[4]
	
	args := "?sign=" . sign . "&buy_key=" . buyKey . "&token=" . token . "&timestamp=" . timestamp . "&duration=" . j.duration

	ai := {}
	ai.albumId := j.albumId
	ai.TrackId := trackId
	ai.Title := j.title
	ai.URL := j.domain . "/download/" . j.apiVersion . fileName . args
	ai.fileName := fileName
	return ai
}

DecryptUrlParams(s) {
	s1 := encrypt3(s)
	s2 := encrypt("xkt3a41psizxrh9l", s1)
	return s2
}

encrypt(e, t) {
	lenE := StrLen(e)
	n := 0
	r := []
	a := 0
	s := ""
	loop, 256 {
		r.Push( A_index - 1 )
	}
	; r := [0, 1, ... 255]
	loop, 256 {
		ro := r[A_index]
		a := Mod( a + ro + Asc( SubStr(e, Mod(A_index-1, lenE) + 1, 1) ) , 256)
		n := ro
		r[A_index] := r[a+1]
		r[a+1] := n
	}
	a := 0, o := 0
	loop, % t.MaxIndex()
	{
		o := Mod( o + 1, 256)
		ro := r[o+1]
		a := Mod( a + ro, 256)
		n := ro
		r[o+1] := r[a+1]
		r[a+1] := n
		s .= chr( t[A_index] ^ r[ Mod(r[o+1]+r[a+1],256) + 1 ] )
	}
	return s
}

encrypt3(s) {
	sLen := StrLen(s)
	t := 0
	n := 0
	r := 0
	i := [] ; []int16
	o := [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1]
	while ( r < sLen ) {
		t := o[1 + ( 255 & Asc(SubStr(s, r + 1, 1)) )]
		; 34, 26,18,54
		r++
		while ( r < sLen and -1 = t ) {
			t := o[1 + ( 255 & Asc(SubStr(s, r + 1, 1)) )]
			r++
		}
		if ( -1 = t ) {
			break
		}

		n := o[1 + ( 255 & Asc(SubStr(s, r + 1, 1)) )]
		r++
		while ( r < sLen and -1 = n ) {
			n := o[1 + ( 255 & Asc(SubStr(s, r + 1, 1)) )]
			r++
		}
		if ( -1 = t ) {
			break
		}
		i.Push( ( t<<2 ) | ( (48&n) >>4 ) )

		t := 255 & Asc(SubStr(s, r + 1, 1))
		r++
		if ( 61 = t ) {
			return i
		}
		t := o[1 + t]
		while ( r < sLen and -1 = t ) {
			t := 255 & Asc(SubStr(s, r + 1, 1))
			r++
			if ( 61 = t ) {
				return i
			}
			t := o[1 + t]
		}
		if ( -1 = t )
			break

		i.Push( ((15&n)<<4)|((60&t)>>2) )

		n := 255 & Asc(SubStr(s, r + 1, 1))
		r++
		if ( 61 = n )
			return i
		n := o[1 + n]
		while ( r < sLen and -1 = n ) {
			n := 255 & Asc(SubStr(s, r + 1, 1))
			r++
			if ( 61 = n )
				return i
			n := o[1 + n]
		}
		if ( -1 = n )
			break
		i.Push( ((3&t)<<6)|n )
	}
	return i
}

DecryptFileName(seed, fileId) { ; �����ļ���
	cgstr := CgHun(seed)
	uri := CgFun(fileId, cgstr)
	if ( "/" != SubStr(uri, 1, 1) ) {
		uri := "/" . uri
	}
	return uri
}

Ran(seed) {
	j := 211 * seed + 30031
	return, Mod(j, 65536)
}

CgHun(seed) {
	CgStr := ""
	key := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\:._-1234567890"
	ka := StrSplit(key)
	
	loop, parse, key
	{
		seed := Ran(seed)
		ran := seed / 65536
		r := 1 + Format("{:d}", ran * ka.MaxIndex())
		CgStr .= ka[r]
		ka.RemoveAt(r)
	}
	return CgStr
}

CgFun(t, cgstr) {
	cg := StrSplit(CgStr)
	strs := StrSplit(t, "*")
	e := ""
	loop, % strs.MaxIndex() - 1
	{
		if ( strs[A_index] != "" ) {
			iii := strs[A_index] + 1
			e .= cg[iii]
		}
	}
	return e
}

getUnixTime(nowTime="20140604170249") {
    nowTime -= 19700101080000, s
	return, nowTime
}



CopyInfo2Clip(Num=1) {
	LV_GetText(NowVar, LV_GetNext(0), Num)
	Clipboard = %NowVar%
	TrayTip, ������:, %NowVar%
}

General_getWDir() { ; ��������ڴ��̣��ͷ�����������Ϊ����Ŀ¼
	DriveGet, DriveStr, List
	if InStr(DriveStr, "T")
		return "T:\"
	else
		return A_WorkingDir
}

/*
# test URL
https://www.ximalaya.com/youshengshu/18372779/
https://www.ximalaya.com/youshengshu/13486515/
https://www.ximalaya.com/youshengshu/3057947/
https://www.ximalaya.com/youshengshu/2696006/

https://www.ximalaya.com/guangbojv/30816438/
https://www.ximalaya.com/youshengshu/22630007/


https://www.ximalaya.com/revision/play/v1/show?id=126192189&sort=0&size=30&ptype=1
	/youshengshu/18372779/126192189
https://www.ximalaya.com/revision/play/v1/audio?id=126192189&ptype=1
https://mpay.ximalaya.com/mobile/track/pay/126192189/1596706117684?device=pc&isBackend=true&_=1596706117684
{
    "albumId": 18372779,
    "apiVersion": "1.0.0",
    "buyKey": "fe4f133ccbf4b22dfa2a1e704ccbbda8",
    "domain": "http://audiopay.cos.xmcdn.com",
    "downloadQualityLevel": true,
    "duration": 469,
    "ep": "ixdsaY59SiQC2v0Mb4wd414PUk0i1ibGSddPKQ7mX3e0nbzYif6Jmu0G1PeIg6E0W+910nFXefEyjPD2y1NE27oPPSxRGqCqXtLGuCFer0Og",
    "fileId": "36*0*7*1*65*31*21*37*53*23*21*44*16*21*40*3*21*39*6*36*13*2*8*53*59*39*47*15*47*0*33*22*48*16*5*59*43*40*64*16*45*48*39*19*23*31*44*56*66*3*27*",
    "highestQualityLevel": 2,
    "isAuthorized": true,
    "msg": false,
    "ret": false,
    "sampleDuration": false,
    "sampleLength": false,
    "seed": 4905,
    "title": "���޵Ŀ����Ǽ��� 005",
    "totalLength": 3800550,
    "trackId": 126192189,
    "uid": 26520310
}
https://audiopay.cos.xmcdn.com/download/1.0.0/group2/M03/6A/54/wKgLdF0nwBeBr-ZjADn95tANjwU326.m4a?sign=46ee50008684d0f68213b0dcf198fa05&buy_key=fe4f133ccbf4b22dfa2a1e704ccbbda8&token=5460&timestamp=1596706122&duration=469

# ������Ч
https://github.com/hkslover/ximalaya/blob/master/main.py
https://github.com/hkslover/ximalaya/blob/master/pay/get_player_url.js

������ϲ�������շѵ���Ѹ����ģ��������ض��˾ͻ�����
http://www.ting199.com/

*/


/*
readme.md @ 2020-08-10

- ����: ��������ϲ�����ŵ������Ƶ�����ۿ�����VIP�˺ŵ�cookie����VIP��δ���ԣ�
- ����: ���ű��еĽ��ܴ��뷭����: (https://github.com/stephenwu2020/ximalaya-dl)
- ����: 
  - ���Ƶ�ַ: `https://www.ximalaya.com/youshengshu/4256765/` �õ� albumId : `4256765`
  - ͨ�� `GetAudioInfo(4256765)` ��ȡjson�����data.src�Ĳ��ŵ�ַ
  - ����õ�ַΪ�գ����� `GetVipAudioInfo(4256765)` ��ȡ���ŵ�ַ������ͻ��õ����ܺ�������ȡ�ļ��������ص�ַ��
  - Ȼ�����wget������m4a/mp3�������������GUI���

*/
