; 分类: 通用函数
; 适用: 原版 L版
; 日期: 2020-08-24

General_getWDir() { ; 如果存在内存盘，就返回它，否则为工作目录
	DriveGet, DriveStr, List
	if InStr(DriveStr, "T")
		return "T:\"
	else
		return A_WorkingDir
}

General_getUnixTime(nowTime="") { ; 返回unix时间戳，参数为空时，使用A_Now
    nowTime -= 19700101080000, s
	return, nowTime
}

General_unixTime2Date(iUnixTime="1598189170408") { ; ret: 20200823212610
	if ( StrLen(iUnixTime) >= 10 ) {
		iTime := SubStr(iUnixTime, 1, 10)
	} else {
		msgbox, 错误：输入时间不是unix时间戳`n%iUnixTime%
	}
	sTime := "19700101080000"
	EnvAdd, sTime, %iTime%, s
	return sTime
}

; {-- 网络

General_getFullURL(ShortURL="xxx.html", ListURL="http://www.xxx.com/45456/238/list.html") {	; 获取完整URL
	If Instr(ShortURL, "https://")
		return, ShortURL
	If Instr(ShortURL, "http://")
		return, ShortURL

	SplitPath, ListURL, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

	Stringleft, ttt, ShortURL, 2
	if ( ttt = "//" ) {
		StringSplit, ff_, ListURL, /
		return, ff_1 . ShortURL
	} else {
		Stringleft, ttt, ShortURL, 1
		If ( ttt = "/" ) {
			return, OutDrive . ShortURL
		} else {
			return, OutDir . "/" . ShortURL
		}
	}
}

; }-- 网络

; 版本 名称
; 5.1 Microsoft Windows XP
; 5.2 Microsoft Windows Server 2003
; 6.0 vista / server 2008
; 6.1 server2008 r2/ win7
; 6.2 win8
; 6.3 Windows 10 Enterprise ; JAVASE6 显示的是 Windows 8 和 6.2
General_getOSVersion(isName=false) {
	if ( isName )
		RegRead, retVar, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, ProductName
	else
		RegRead, retVar, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion
	return retVar
}

General_isTouchScreen() { ; 是否触摸屏
	RegRead, xx, HKLM, SOFTWARE\Microsoft\Windows\Tablet PC, IsTabletPC ; win10TouchPad: IsTabletPC=2753, DeviceKind=193
	if ( ErrorLevel ) ; 非触摸屏
		return, false
	else
		return, xx
}

; 通过修改host文件来设置DNS
General_setDNS(iHost="www.biquge.com.tw", iIP="119.147.134.202")
{
	fileread, hh, %A_WinDir%\system32\drivers\etc\hosts
	if ( ! instr(hh, iHost) ) {
		fileappend, %iIP%  %iHost%`r`n, %A_WinDir%\system32\drivers\etc\hosts
	} else {
		newHost := ""
		loop, parse, hh, `n, `r
		{
			if ( instr(A_LoopField, iHost) ) {
				if ( "" = iIP ) ; iIP为空，删除记录
					Continue
				newHost .= iIP . A_Space . A_Space . iHost . "`r`n"
			} else {
				newHost .= A_LoopField . "`r`n"
			}
		}
		StringReplace, newHost, newHost, `r`n`r`n`r`n, `r`n`r`n, A
		fileappend, %newHost%, %A_WinDir%\system32\drivers\etc\hosts.new
		FileMove, %A_WinDir%\system32\drivers\etc\hosts.new, %A_WinDir%\system32\drivers\etc\hosts, 1
	}
}

; {-- 文件

General_GetCFG(IniSection="Global", IniKey="wDir") { ; 读取 FoxCFG.ini配置文件中的值
	Static IniPath := ""
	If ( "" = IniPath ) ; 获取配置文件路径
		IniPath := General_GetPath("FoxCFG.ini", "\bin\autohotkey\fox_scripts\", "CD")
	IniRead, OutputVar, %IniPath%, %IniSection%, %IniKey%, %A_space%
	return, OutputVar
}

General_SetCFG(IniSection="FilePath", IniKey="XXX", IniValue="YYY") {
	Static IniPath := ""
	If ( "" = IniPath ) ; 获取配置文件路径
		IniPath := General_GetPath("FoxCFG.ini", "\bin\autohotkey\fox_scripts\", "CD")
	IniWrite, %IniValue%, %IniPath%, %IniSection%, %IniKey%
}

General_GetPath(inFileName="xxx.ooo", mayDir="\bin\,\Program Files\", mayDrive="CD") {
	loop, parse, mayDrive
	{
		nowDrive := A_loopfield
		loop, parse, mayDir, `,
		{
			nowPath := nowDrive . ":" . A_LoopField . "\" . inFileName
			StringReplace, nowPath, nowPath, \\, \, A
			IfExist, %nowPath%
				return, nowPath
		}
	}
}

General_GetFilePath(NowFileName="FreeImage.dll", DirList="C:\bin\bin32|D:\bin\bin32|C:\Program Files|D:\Program Files") { ; 获取文件路径
	static LastDir
	if ( LastDir != "" )
		ifExist, %LastDir%\%NowFileName%
			return, LastDir . "\" . NowFileName
	loop, parse, DirList, |
		IfExist, %A_LoopField%\%NowFileName%
		{
			LastDir := A_LoopField
			Break
		}
	if ( LastDir = "" ) { ; 未在给定路径中找到,去环境变量中寻找
		EnvGet, PosSysDirs, Path
		loop, parse, PosSysDirs, `;, %A_space%
			IfExist, %A_LoopField%\%NowFileName%
			{
				LastDir := A_LoopField
				Break
			}
	}
	if ( LastDir != "" )
		TarPath := LastDir . "\" . NowFileName
	return, TarPath
}
; }-- 文件


; {-- 加解密
General_UUID(c = false) { ; http://www.autohotkey.net/~polyethene/#uuid
	static n = 0, l, i
	f := A_FormatInteger, t := A_Now, s := "-"
	SetFormat, Integer, H
	t -= 1970, s
	t := (t . A_MSec) * 10000 + 122192928000000000
	If !i and c {
		Loop, HKLM, System\MountedDevices
		If i := A_LoopRegName
			Break
		StringGetPos, c, i, %s%, R2
		StringMid, i, i, c + 2, 17
	} Else {
		Random, x, 0x100, 0xfff
		Random, y, 0x10000, 0xfffff
		Random, z, 0x100000, 0xffffff
		x := 9 . SubStr(x, 3) . s . 1 . SubStr(y, 3) . SubStr(z, 3)
	} t += n += l = A_Now, l := A_Now
	SetFormat, Integer, %f%
	Return, SubStr(t, 10) . s . SubStr(t, 6, 4) . s . 1 . SubStr(t, 3, 3) . s . (c ? i : x)
}
; }-- 加解密

/*
; No One Use
General_uXXXX2CN(uXXXX) ; in: "\u7231\u5c14\u5170\u4e4b\u72d0"  out: "爱尔兰之狐"
{
	StringReplace, uXXXX, uXXXX, \u, #, A
	cCount := StrLen(uXXXX) / 5
	VarSetCapacity(UUU, cCount * 2, 0)
	cCount := 0
	loop, parse, uXXXX, #
	{
		if ( "" = A_LoopField )
			continue
		NumPut("0x" . A_LoopField, &UUU+0, cCount)
		cCount += 2
	}
	if ( A_IsUnicode ) {
		return, UUU
	} else {
		GeneralA_Unicode2Ansi(UUU, rUUU, 0)
		return, rUUU
	}
}

*/

