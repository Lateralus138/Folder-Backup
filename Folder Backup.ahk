; Backup a folder and it's contents

; Init
#Include, WinGuiLib_FB.ahk
#Include, funcs_FB.ahk
SetBatchLines,-1
SetWorkingDir %A_ScriptDir%
#SingleInstance,Force
OnMessage(0x201,"WM_LBUTTONDOWN")
OnMessage(0x200,"WM_MOUSEHOVER")
; Vars
InitVars()

; Get 7-zip command line tool if not found in this apps directory
If InStr(FileExist(temp),"D") {
	Try FileRemoveDir,%temp%,1
	Catch e {
		MsgBox,20,NPS - Folder Backup Error, % "Temporary folder:`n" temp "`ncould not be deleted. Would you`nlike to try to delete it manually?"
		IfMsgBox, Yes
			Run, % GetMainDrive(":\")
	}
}
If !FileExist(7z) {
	If Is64bitOS()
		UrlDownloadToFile,http://srv70.putdrive.com/putstorage/DownloadFileHash/1AE452813A5A4A5QQWE2355891EWQS/7z.exe ,% 7z
	Else
		UrlDownloadToFile,http://37.59.32.118/putstorage/DownloadFileHash/EC0B262C3A5A4A5QQWE638814EWQS/7z.exe ,% 7z	
}
If ErrorLevel {
	MsgBox,16,NPS - Folder Backup Error,	%	"7zip could not be found and could not be downloaded.`n"
	
	.	"It is possible that you have blocked this program from`n"
									.	"the internet or you do not have permissions in the`n"
									.	"programs folder."
	ExitApp
}
; Build menus, intial loops and guis here
; Tray Menu

Menu,Tray,NoStandard
Menu,Tray,Add,&About NPS - Folder Backup,About
Menu,Tray,Add,E&xit,GuiClose

; Main Gui
Gui,New
Gui, -Caption +Border
Gui,Color,0xFFFFFF
Gui,Margin,1,1
Gui,Add,Progress,x1 y0 h30 c0x2b5797 Background0x2b5797,100
Gui,Font,s12 c0xFEFEFA w700,Segoe UI
Gui,Add,Text,xp yp h30 +BackgroundTrans 0x200,%A_Space%NPS - Folder Backup
Gui,Font,c0x2b5797
Gui,Add,Text,Section xp y+1 +BackgroundTrans,%A_Space%Directory:
Gui,Font,c0xee1111 w200,Consolas
Gui,Add,Edit,x+8 0x200 vEditText w%lw%,%folder%
Button("Browse Folder",,,,,0,,,500)
Gui,Show,AutoSize,NPS - Folder Backup
GetControls("NPS - Folder Backup")
Gui,Font,s12 c0x2b5797 w700,Segoe UI
Gui,Add,Text,x%S2X% y+4 0x200 +BackgroundTrans,%A_Space%Name:
Gui,Show,AutoSize,NPS - Folder Backup
GetControls("NPS - Folder Backup")
egap:=(S4W > S2W)?lw-(S4W-S2W-1):lw
newE2X:=(egap == lw)?E1X-1:"+6"
Gui,Font,c0xee1111 w200,Consolas
Gui,Add,Edit,x%newE2X% yp 0x200 vbfile w%egap%,%bfile%
Gui,Show,AutoSize,NPS - Folder Backup
GetControls("NPS - Folder Backup")
rw:=S3W-4
Gui,Font,c0x2b5797 s10,Segoe UI
Gui,Add,CheckBox,x+4 yp w%rw% vrecurse Checked 0x1,Recurse
Gui,Add,CheckBox,xp y+0 w%rw% vUpdate Checked 0x1,Update Existing
Gui,Add,ComboBox,xp y+4 w%rw% vfType Choose1 gArchiveType,7z|Zip
Gui,Show,AutoSize,NPS - Folder Backup
GetControls("NPS - Folder Backup")
Gui,Font,s8
Gui,Add,Text,xp+12 y+4 0x2,Compression:`nLevel:
Gui,Font,s10
Gui,Add,Edit,x+5 yp w38
Gui,Add,UpDown,w%rw% vCompLvl Range1-9,9
Button("About",S1X-8,S4Y2+32,S2W+5)
Button("Backup Folder",E1X-1,S4Y+E2H,E1W,60,0,4,13)
Gui,Show,AutoSize,NPS - Folder Backup
GetControls("NPS - Folder Backup")
If (S2H != MP2H)
	GuiControl,Move,Static2, h%MP2H%
If (E1H != MP2H)
	GuiControl,Move,Edit1,w%E1W% h%MP2H%
Gui,Font,c0x2b5797 s10,Segoe UI
Gui,Show,AutoSize,NPS - Folder Backup
GetControls("NPS - Folder Backup")
WinGetPos,wx,wy,ww,wh,NPS - Folder Backup
MinButton("0xFEFEFA","0xFEFEFA",ww-52,MP1H-10)
XButton("0xFEFEFA","0xFEFEFA",ww-28,MP1H-26)
www:=ww-2
Gui,Font,s9
Gui,Add,StatusBar,y+4 vStatusA Background0xFFFFFF
Gui,Show,AutoSize,NPS - Folder Backup
GetControls("NPS - Folder Backup")
Gui, +LastFound
did:="ahk_id " WinExist()
SB_SetText("Status:")
ControlSend,Edit1,{End},NPS - Folder Backup
GuiControl,Move,msctls_progress321, w%www%
GuiControl,Move,Static1, w%www%
GuiControl,MoveDraw,Static7
Gui,Show,AutoSize Center,NPS - Folder Backup
Gui,Submit,NoHide
GetControls("NPS - Folder Backup")
OnExit,GuiClose
; End auto execute
Return

; Hotkeys


; Functions

; Classes


; Subs
CmbMsg:
	If MouseOver(E3X,E3Y,E3X2,E3Y2){
		ToolTip % "Choose your archive type from this list."
		SetTimer,TT_OUT,-1500
	}
Return
ArchiveType:
	Gui,Submit,NoHide
Return
TT_OUT:
	TT_FADE("Out")
Return
Browse:
	Gui,Submit,NoHide
	lastfolder:=folder
	SetTimer,fsf,100
	FileSelectFolder,folder,% GetMainDrive(":\"),3,Select a folder to backup:
	SetTimer,fsf,Off
	folder:=!folder?lastfolder:folder
	GuiControl,,EditText,%folder%
Return
fsf:
	IfWinExist,Browse For Folder
		{
			OuterDock(did,"Browse For Folder")
			WinMove,Browse For Folder,	,,	,	% round(window._w(did)+14)
											,	% round(window._h(did)*1.5)		
		}
Return
RunBackup:
	Gui,Submit,NoHide
	bfile:=bfile?bfile:"backup_" A_DD "_" A_MM "_" A_YYYY
	If recurse
		SetTimer,bur,-1
	Else
		SetTimer,bu,-1
Return
bur:
	SetTimer,7zrename,-1
	BackupFolder(folder,fType,1,,CompLvl,Update)
Return
bu:
	SetTimer,7zrename,-1
	BackupFolder(folder,fType,,,CompLvl,Update)
Return
7zrename:
	If !zid:=WinExist("ahk_exe 7z.exe")?"ahk_id " WinExist("ahk_exe 7z.exe"):0 {
		SetTimer,7zrename,-1
		Return
	}
	WinGetTitle,7zname,%zid%
	If (7zname != "NPS - Folder Backup - compressing files...")
		WinSetTitle,%7zid%,,NPS - Folder Backup - compressing files...
	If OuterDock(did,zid)
		WinMove,% zid,	,,	,	% round(window._w(did)+14)
							,	% round(window._h(did)*1.5)
	SetTimer,7zrename,-1
Return
About:
	SetTimer,AboutDock,-1
	Gui,About:New
	Gui,About:+AlwaysOnTop
	Gui,About:Color,0xFEFEFA
	;Gui,About:Add,Progress,+0x4000000 x0 y0 w400 h200 c0x2b5797 Background0xFEFEFA,100
	Gui,About:Margin,0,0
	Gui,About:Font,s12 c0x2b5797,Segoe UI
	Gui,About:Add,Text,Section xp+4 yp+2 w392 +BackgroundTrans,	%	"NPS - Folder Backup is a lightweight program to quickly`n"
																	.	"backup any folder on your computer using the 7zip`n"
																	.	"compression command line utility. For more information`n"
																	.	"on 7zip compression visit:"
	Gui,About:Add,Link,xp y+4 gLinkA, <a>Official 7zip Website</a>
	Gui,About:Font,s14 c0x2b5797,Segoe UI
	;Gui,About:Add,Button,x+205 yp-20 h21 gAboutGuiClose,Exit
	Gui,About:-Caption +ToolWindow +Border
	SetTimer,AboutOut,-1
	Gui,About:Show,w400 h113 Center,About NPS - Folder Backup
	ControlGetPos,AB1X,AB1Y,AB1W,AB1H,Button1,About NPS - Folder Backup
	Gui,About:Add,Picture,x364 y76 w32 h32 gClick Icon11 +BackgroundTrans,C:\Windows\System32\comres.dll
	Gui,About:Add,Progress,+0x4000000 x0 y0 w400 h113 c0xFEFEFA Background0x2b5797,100
	Gui,About:Show,AutoSize,About NPS - Folder Backup
Return
AboutDock:
	OuterDock(did,"About NPS - Folder Backup")
	SetTimer,AboutDock,-1
Return
Click:
	ButtonClick("Static2","*Icon11 C:\Windows\System32\comres.dll","*Icon9 C:\Windows\System32\comres.dll")
    ; GuiControl, -Redraw,     Static2
    ; GuiControl,,             Static2,*Icon9 C:\Windows\System32\comres.dll
    ; GuiControl, +Redraw,    Static2
    ; KeyWait, LButton, Up
    ; GuiControl, -Redraw,     Static2
    ; GuiControl,,             Static2,*Icon11 C:\Windows\System32\comres.dll
    ; GuiControl, +Redraw,    Static2
	Gosub,AboutGuiClose
Return
LinkA:
	Run, http://www.7-zip.org/
	SetTimer,AboutGuiClose,-1
Return
AboutOut:
	TT_FADE("in",16,,"About NPS - Folder Backup")
Return
AboutGuiClose:
AboutGuiEscape:
	SetTimer,AboutDock,Off
	Gui,About:Destroy
Return
E&xit:
GuiClose:
	SetTitleMatchMode,3
	IfWinExist,About NPS - Folder Backup
		Gui,About:Destroy
	Gui,Destroy
	ExitApp
