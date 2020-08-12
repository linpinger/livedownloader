; 作者不知道是谁了
; 放到论坛里了: https://www.autohotkey.com/boards/viewtopic.php?f=28&t=79764

/*
; 下面是加密

	oldStringCaseSense := A_StringCaseSense
	StringCaseSense On 
	Chars = ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/

	strA := "falksjd|fjlks>fksdj,234alsdjaa"
	strE := "ZmFsa3NqZHxmamxrcz5ma3NkaiwyMzRhbHNkamFh"
	msgbox, % Base64(strA) "`n" strE

	StringCaseSense %oldStringCaseSense%
return
*/

Base64(string)
{
   Loop Parse, string
   {
      If Mod(A_Index,3) = 1
         buffer := Asc(A_LoopField) << 16
      Else If Mod(A_Index,3) = 2
         buffer += Asc(A_LoopField) << 8
      Else {
         buffer += Asc(A_LoopField)
         out := out . Code(buffer>>18) . Code(buffer>>12) . Code(buffer>>6) . Code(buffer)
      }
   }
   If Mod(StrLen(string),3) = 0
      Return out
   If Mod(StrLen(string),3) = 1
      Return out . Code(buffer>>18) . Code(buffer>>12) "=="
   Return out . Code(buffer>>18) . Code(buffer>>12) . Code(buffer>>6) "="
}

InvBase64(code)
{
   StringReplace code, code, =,,All
   Loop Parse, code
   {
      If Mod(A_Index,4) = 1
         buffer := DeCode(A_LoopField) << 18
      Else If Mod(A_Index,4) = 2
         buffer += DeCode(A_LoopField) << 12
      Else If Mod(A_Index,4) = 3
         buffer += DeCode(A_LoopField) << 6
      Else {
         buffer += DeCode(A_LoopField)
         out := out . Chr(buffer>>16) . Chr(255 & buffer>>8) . Chr(255 & buffer)
      }
   }
   If Mod(StrLen(code),4) = 0
      Return out
   If Mod(StrLen(code),4) = 2
      Return out . Chr(buffer>>16)
   Return out . Chr(buffer>>16) . Chr(255 & buffer>>8)
}

Code(i)     ; <== Chars[i & 63], 0-base index
{
   Global Chars
   StringMid i, Chars, (i&63)+1, 1
   Return i
}

DeCode(c)   ; c = a char in Chars ==> position [0,63]
{
   Global Chars
   Return InStr(Chars,c,1) - 1
}


