;CheckPage(bap)
; Function library for AutoExvius

; Init
InitVars(){
	Global
	SplitPath,A_Desktop,,,,,drive
	7z:=A_WorkingDir "\7z.exe"
	lw:=450
	folder:=A_MyDocuments
	bfile:="backup_" A_MM "-" A_DD "-" A_YYYY 
	backup:=A_Desktop "\" bfile ".7z"
	temp:=drive "\NPS - Folder Backup"
}
GetMainDrive(append:=""){
	Return SubStr(A_Desktop,1,1) append
}
; Function
Squares(bg:="0x1D1D1D",c:="0xFEFEFA",x:="p",y:="p",w:=4,h:=4){
	Gui, Add,Progress,x%x% y%y% Background%bg% c%c% w%w% h%h%,100
}
XButton(bg:="0x1D1D1D",c:="0xFEFEFA",initx:="p",inity:="p",w:=4,h:=4){
	wd:=w*2,hd:=h*2,wt:=w*3,ht:=h*3
	Squares(bg,c,initx,inity,w,h)
	Squares(bg,c,"+0","+0",w,h)
	Squares(bg,c,"+0","+0",w,h)
	Squares(bg,c,"p-" w,"+0",w,h)
	Squares(bg,c,"p-" w,"+0",w,h)
	Squares(bg,c,"+" wd,"p-" ht,w,h)
	Squares(bg,c,"+0","p-" h,w,h)
	Squares(bg,c,"p-" w,"+" hd,w,h)
	Squares(bg,c,"+0","+0",w,h)
}
MinButton(bg:="0x1D1D1D",c:="0xFEFEFA",initx:="p",inity:="p",w:=4,h:=4){
	Squares(bg,c,initx,inity,w,h)
	Loop, 4
		Squares(bg,c,"+0",,w,h)
}
WM_MOUSEHOVER(){
	Global
	Local over
	over:=MouseOver(CB1X,CB1Y,CB1X2,CB1Y2)
	If (over == 1){
		SetTimer,CmbMsg,-1500
	}
}
WM_LBUTTONDOWN(){
	Global
	IfWinNotExist,About NPS - Folder Backup
		{
			If MouseOver(MP5X,MP10Y,MP9X2,MP5Y2) {
				TT_FADE("Out",16,,"NPS - Folder Backup",1)
			}
			If MouseOver(MP10X,MP10Y,MP18X2,MP18Y2) {
				TT_FADE("Out",,,"NPS - Folder Backup")
			}
			If MouseOver(MP2X,MP2Y,MP2X2,MP2Y2) {
				Gosub,Browse
			}
			If MouseOver(MP1X,MP1Y,MP1X2,MP1Y2) {
				PostMessage, 0xA1, 2,,, NPS - Folder Backup
			}
			If MouseOver(MP3X,MP3Y,MP3X2,MP3Y2) {
				Gosub,About
			}
			If MouseOver(S7X,S7Y,S7X2,S7Y2) {
				Gosub,RunBackup
			}
		}
}
ButtonClick(control,upImg,dwnImg){
    GuiControl,-Redraw,% control
    GuiControl,,% control,% dwnImg
    GuiControl,+Redraw,% control
	KeyWait, LButton, Up
    GuiControl,-Redraw,% control
    GuiControl,,% control,% upImg
    GuiControl,+Redraw,% control
}
GetClientToWin(hwnd,x:=0,y:=0,ret:="xy")
{
    VarSetCapacity(pt, 8)
    NumPut(x, pt, 0)
    NumPut(y, pt, 4)
    DllCall("ClientToScreen", "uint", hwnd, "uint", &pt)
    WinGetPos, wx, wy,,, ahk_id %hwnd%
    x := NumGet(pt, 0, "int") - wx
    y := NumGet(pt, 4, "int") - wy
	Return (ret == "xy")?x " " y:(ret == "x")?x:y
}
FADE(win){
	id:=WinExist(win)
	DllCall("AnimateWindow","UInt",id,"Int",2000,"UInt","0x20010")
	Sleep,1000
	DllCall("AnimateWindow","UInt",id,"Int",1000,"UInt","0x10010")
}
FadeOut(win:="ahk_class tooltips_class32",dur:=500){
	id:=WinExist(win)
	DllCall("AnimateWindow"	
			,"UInt",id
			,"Int",dur
			,"UInt","0x10010")
	If (win == "ahk_class tooltips_class32")
		ToolTip
	Else
		WinClose,ahk_id %id%
}
WM_LBUTTONUP(){
}
Class Globals { ; my favorite way to set and retrive global tions. Good for
	SetGlobal(name,value=""){ ; setting globals from other tions
		Global
		%name%:=value
		Return
	}
	GetGlobal(name){	
		Global
		Local var:=%name%
		Return var
	}
}
TT_FADE(state,inc:=8,max:=255,win:="ahk_class tooltips_class32",min:=0){
	SetTitleMatchMode,3
	c:=InStr(state,"in")?-1
	:InStr(state,"out")?255
	:0
	If (!c || !inc || !max || !WinExist(win)) 
		Return 0
	BlockInput,On
	Loop
		{
			Sleep, 1
			SetTrans(win,c)
			If InStr(state,"in")
				{
					If (c >= max)
						Break
					c+=inc
				}
			Else
				{
					If (c <= -1 && win == "ahk_class tooltips_class32")
						{
							ToolTip
							Break
						}
					If (c <= -1 && win != "ahk_class tooltips_class32")
						{
							SetTrans(win,0)
							If !min
								WinClose, % "ahk_id " WinExist(win)
							Else
								{
									WinMinimize, % "ahk_id " WinExist(win)
									SetTrans(win,255)
									WinShow, % "ahk_id " WinExist(win)
								}
							Break
						}
					c-=inc				
				}
		}
	BlockInput,Off
	;WinActivate, ahk_class Shell_TrayWnd
	Return 1
}	
SetTrans(win,trans){
	win:=WinExist(win)
	l:= DllCall("GetWindowLong", "Uint", win, "Int", -20)
	DllCall("SetWindowLong", "UInt", win, "Int", -20, "UInt", l|0x00080000)
	Return DllCall("SetLayeredWindowAttributes"
					,"uint",win,"uint",0
					,"uchar",trans,"uint",2)
}
GetReg(key,value:=False){
	RegRead,a,% key,% value
	Return a
}


Button(txt,x:=0,y:=0,w:=0,h:=0,xgap:=8,ygap:=8,fs:=10,wt:=400,ft:="Segoe UI",c:="0x2b5797",tc:="0xFEFEFE"){
	w:=!w?Ceil(StrLen(txt)*fs):w,h:=!h?Ceil(fs*3):h
	
	If (!x && !y)
		Gui,Add,Progress,x+%xgap% yp w%w% h%h% c%c% Background%c%,100
	Else
		{
			x:=x+xgap,y:=y+ygap
			Gui,Add,Progress,x%x% y%y% w%w% h%h% c%c% Background%c%,100
		}
	Gui,Font,s%fs% w%wt%,%ft%
	Gui,Add,Text,xp yp w%w% h%h% c%tc% 0x1 0x200 +BackgroundTrans,% txt
}
BackupFolder(dir,ftype:="7z",rec:=0,list:=0,compress:=9,ud:=1) {
	Global 7z,drive,backup,temp,bfile
	StringLower,ftype,ftype
	backup:=A_Desktop "\" bfile "." ftype
	If !FileExist(dir)
		Return 
	files:={},paths:={},incl:=rec
	SetWorkingDir,%dir%
	If rec {
		ControlSetText,msctls_statusbar321,% "Status: Creating temporary sub-directories...",NPS - Folder Backup
		Loop,*.*,2,%rec%
			{
				paths.Push(A_LoopFileFullPath)
				FileCreateDir,% temp "\" paths[A_Index]
				ControlSetText,msctls_statusbar321,% "Status: " temp "\" paths[A_Index] " created.",NPS - Folder Backup
			}
	}
	If !InStr(FileExist(temp),"D") {
		FileCreateDir,% temp
		ControlSetText,msctls_statusbar321,% "Status: " temp " created as a temporary working folder.",NPS - Folder Backup
	} Else {
			FileDelete,% temp
			ControlSetText,msctls_statusbar321,% "Status: Deleted the old temporary working folder.",NPS - Folder Backup
			FileCreateDir,% temp
			ControlSetText,msctls_statusbar321,% "Status: " temp " created as a temporary working folder.",NPS - Folder Backup
		}
	Loop,*.*,%incl%,%rec%
		{
			If A_LoopFileAttrib not contains H,R,S 
				{
					FileCopy,% A_LoopFileFullPath,% temp "\" A_LoopFileFullPath
					ControlSetText,msctls_statusbar321,% "Status: Copied file: " A_LoopFileName " to temp folder: " temp "\" A_LoopFileDir " for backup.",NPS - Folder Backup
				}
			If list
				files.=A_LoopFileFullPath "`n"
			Else
				files.Push(A_LoopFileFullPath)
		}
	If !files.MaxIndex() {
		ControlSetText,msctls_statusbar321,% "Status: No files found to backup in folder: " dir,NPS - Folder Backup
		Return
	}
	If !ud {
		If FileExist(backup) {
			FileDelete,%backup%
			ControlSetText,msctls_statusbar321,% "Status: Deleted old backup " backup " since your will not be updating.",NPS - Folder Backup
		}
	}
	ControlSetText,msctls_statusbar321,% "Status: Compressing folder to archive located at:`n" backup,NPS - Folder Backup
	RunWait, %7z% a -mx%compress% "%backup%" "%temp%\*"
	FileRemoveDir,%temp%,1
	ControlSetText,msctls_statusbar321,% "Status: Old temporary folder " temp " deleted.",NPS - Folder Backup
	Sleep, 3000
	ControlSetText,msctls_statusbar321,% "Status: Backup completed. Your archive is located at: " backup,NPS - Folder Backup
	Return files
}
Is64bitOS() {
    return (A_PtrSize=8)
        || DllCall("IsWow64Process"
		, "ptr", DllCall("GetCurrentProcess")
		, "int*", isWow64)
        && isWow64
}
OuterDock(prnt,chld,pos:="b",mtchmda:=3,mtchmdb:=3){
	SetTitleMatchMode,% mtchmda
	prntx:=WinExist(prnt)
	SetTitleMatchMode,% mtchmdb
	chldx:=WinExist(chld)
	If pos in b,bottom
		pos:="b"
	If pos in t,top
		pos:="t"
	If pos in l,left
		pos:="l"
	If pos in r,right
		pos:="r"
	If pos Not In b,t,l,r
		nopos:=1
	If (!prntx || !chldx || nopos)
		Return
	SetTitleMatchMode,% mtchmda
	IfWinExist,% prnt 
		{
			SetTitleMatchMode,% mtchmdb
			IfWinExist,% chld
				{
					If (pos == "b" || pos == "t"){
						w1:=window._w(prnt,mtchmda),w2:=window._w(chld,mtchmdb),x1:=window._x(prnt,mtchmda)
						x:=(w2<=w1)?x1+((w1/2)-(w2/2)):x1-((w2/2)-(w1/2))
						y:=	(pos == "b")?(window._y(prnt,mtchmda)+window._h(prnt,mtchmda))
						:	(pos == "t")?window._y(prnt,mtchmda)-window._h(chld,mtchmdb)
						: 	0
					} Else {
						h1:=window._h(prnt,mtchmda),h2:=window._h(chld,mtchmdb),y1:=window._y(prnt,mtchmda)
						y:=(h2<=h1)?y1+((h1/2)-(h2/2)):y1-((h2/2)-(h1/2))
						x:=	(pos == "l")?(window._x(prnt,mtchmda)-window._w(chld,mtchmdb))
						:	(pos == "r")?window._x(prnt,mtchmda)+window._w(prnt,mtchmda)
						: 	0
					}
					WinMove,% chld,,% x,% y
				}
		}
	Return 1
}
; Classes


; Sub

