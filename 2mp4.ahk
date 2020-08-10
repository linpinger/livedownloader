	verDate := "2020-07-03"

	wDir := General_getWDir() ; T:\, A_WorkingDir

	mkvmgPath  := "D:\bin\mkvtoolnix\mkvmerge.exe"
;	ffmpegPath := "D:\bin\mplayer\ffmpeg_xp.exe"
	ffmpegPath := "ffmpeg.exe"

Gui, +AlwaysOnTop                    

	Gui,Add,Groupbox,x14 y7 w280 h230 cBlue, 多个文件拖动到下面:
	Gui,Add, Edit,x24 y27 w260 h196 vFileList

	Gui,Add,Button,x304 y17 w130 h40 gMerge2Mp4, 合并为mp4
	Gui,Add,Button,x304 y77 w130 h40 gDirect2Mp4, 顺序转为mp4
	Gui,Add,Button,x304 y137 w130 h40 gExtractAudio, 提取音频m4a

	Gui,Add,Button,x374 y197 w60 h40 gDeleFiles, 删除列表中的文件
	Gui,Add,Button,x304 y197 w60 h40 gCleanList, 清空列表

	Gui, Add, ComboBox, x142 y0 w140 h20 R10 Choose1 vTarDir, %wDir%|源文件所在目录|T:\|%A_WorkingDir%|D:\tmp|C:\etc

	Gui, Add, StatusBar,, 用法：拖动文件到大文本框中，[选择导出目录]，然后按按钮
	Gui,Show, w440 h260 , 换马甲  版本: %verDate%

Return 

parsePaths( iPathStr ) {
	fa := []
	loop, parse, iPathStr, `n, `r
	{
		if ( "" = A_LoopField )
			continue
		fa.Push(A_LoopField)
	}
	return fa
}

getSelectedPaths() {
	Clipboard =
	send ^c
	ClipWait
	fList = %Clipboard%
	return fList
}


Merge2Mp4:
	GuiControlGet, TarDir
	GuiControlGet, FileList
	fa := parsePaths( FileList )

	WHStr := getVideosWHs( FileList )
	SB_SetText("各宽高: " . WHStr)

	firstPath := fa[1]
	SplitPath, firstPath , OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

	pathList := ""
	for idx, npath in fa
		pathList .= npath . A_space
;	msgbox, % fa.Length() "`n" fa[1] "`n" OutNameNoExt "`n" pathList

	if ( TarDir != "源文件所在目录" )
		OutDir := TarDir
	runwait, %mkvmgPath% -o %OutDir%\%OutNameNoExt%.mkv "[" %pathList% "]"

	savePath := getSavePath(OutDir . "\" . OutNameNoExt . ".mp4")
	runwait, %ffmpegPath% -i %OutDir%\%OutNameNoExt%.mkv -vcodec copy -acodec copy -movflags faststart %savePath%

	FileDelete, %OutDir%\%OutNameNoExt%.mkv ; 删除mkv

	TrayTip, merge:, done
return

getSavePath(iPath="") {
	oPath := iPath
	IfExist, %iPath%
	{
		SplitPath, iPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		oPath := OutDir . "\" . OutNameNoExt . "_merge." . OutExtension
	}
	return oPath
}

Direct2Mp4:
	AddArg := "-bsf:a aac_adtstoasc" ; GuanChan: ts转mp4
	GuiControlGet, TarDir
	GuiControlGet, FileList
	loop, parse, FileList, `n, `r
	{
		if ( "" = A_LoopField )
			Continue

		SplitPath, A_LoopField, OutFileName, OutDir, OutExt, OutNameNoExt, OutDrive
		cmdstr =  %ffmpegPath% -y -i "%A_LoopField%" -movflags faststart -vcodec copy -acodec copy %AddArg% "%OutNameNoExt%.mp4"
		if ( TarDir != "源文件所在目录" )
			OutDir := TarDir
		runwait, %cmdstr%, %OutDir% ;, Min
;		clipboard = %cmdstr%
	}
;	TrayTip, direct:, done
return

ExtractAudio:
	GuiControlGet, TarDir
	GuiControlGet, FileList
	loop, parse, FileList, `n, `r
	{
		if ( "" = A_LoopField )
			Continue

		SplitPath, A_LoopField, OutFileName, OutDir, OutExt, OutNameNoExt, OutDrive
		cmdstr =  %ffmpegPath% -i "%A_LoopField%" -vn -acodec copy "%OutNameNoExt%.m4a"
		if ( TarDir != "源文件所在目录" )
			OutDir := TarDir
		runwait, %cmdstr%, %OutDir% ;, Min
;		clipboard = %cmdstr%
	}
;	TrayTip, direct:, done
return

DeleFiles:
	GuiControlGet, FileList
	loop, parse, FileList, `n, `r
	{
		if ( "" = A_LoopField )
			Continue
		FileDelete, %A_LoopField%
	}
	gosub, CleanList
return

CleanList:
	GuiControl, , FileList
return

; ----------- 处理: 拖动事件
GuiDropFiles:
	File_full_path := A_GuiEvent
	if ( A_guicontrol = "FileList" ) {
		GuiControlGet, FileList
		FileList .= File_full_path . "`n"
		GuiControl, , FileList, %FileList%
	}
	if ( A_guicontrol = "" )
		TrayTip, 提示:, 要将文件拖动到框框里面
return

GuiClose: 
GuiEscape:
!esc::
ExitApp

^esc::reload
+esc::Edit


getVideosWHs( iPathStr ) {
	oStr := ""
	loop, parse, iPathStr, `n, `r
	{
		if ( "" = A_LoopField )
			continue
		oStr .= getWHStr(A_LoopField) . A_space
	}
	return oStr
}
getWHStr(VideoPath="") {
	global ffmpegPath
	GuiControlGet, TarDir
	if ( TarDir != "源文件所在目录" ) {
		tmpPath := TarDir . "\" . A_now . ".videoinfo"
	} else {
		tmpPath := A_temp . "\" . A_now . ".videoinfo"
	}

	runwait, cmd /c %ffmpegPath% -i "%VideoPath%" 2> "%tmpPath%", , Hide
	FileRead, txt, %tmpPath%
	FileDelete, %tmpPath%

;     Stream #0:0(und): Video: h264 (High) (avc1 / 0x31637661), yuvj420p(pc), 544x960, 1614 kb/s, 18 fps, 18 tbr, 16k tbn, 32k tbc (default)
;     Stream #0:0: Video: h264 (High), yuv420p(tv, bt709), 1280x720, 1536 kb/s, 30.30 fps, 30 tbr, 1k tbn, 60 tbc
	line := ""
	loop, parse, txt, `n, `r
	{
		if ( InStr(A_loopfield, "Stream") and InStr(A_loopfield, "Video:") ) {
			line := A_loopfield
			break
		}
	}

	wh := "" ; 544x960
	loop, parse, line, `,, %A_space%
	{
		if ( InStr(A_loopfield, "x") and ! InStr(A_loopfield, " 0x") ) {
			wh := A_loopfield
			break
		}
	}
	if ( "" = wh ) {
		clipboard = %line%
		msgbox, %line%`n%wh%
	}
	return wh
}

