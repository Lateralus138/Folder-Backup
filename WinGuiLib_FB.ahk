/* 
Library of Lateralus138's window functions, objects, and classes for AutoHotkey.
GuiLib also provides a basic screen/window interface, (API you might say)
for better window/window placement and manipulation. Plans to make this as 
universal as possible. Email: faithnomoread@yahoo.com for help, suggestions,
or possible collaboration.
*/


; Functions
; Is64Bit() {
   ; return (RegexMatch(EnvGet("Processor_Identifier"), "^[^ ]+64") > 0)
; }
GetControls(title,control:=0,posvar:=0) {
	;Gui,Show,AutoSize,%title%
	If !id:=WinExist(title)?"ahk_id " WinExist(title):""
		Return
	If (control && posvar)
		{
			namenum:=EnumVarName(control)
			ControlGetPos,x,y,w,h,%control%,%title%
			pos:=(posvar == "X")?x
			:(posvar == "Y")?y
			:(posvar == "X2")?x+w
			:(posvar == "Y2")?Y+H
			:0
			Globals.SetGlobal(namenum posvar,pos)
			Return pos
		}
	Else If !(control && posvar)
		{
			WinGet,a,ControlList,%title%
			Loop,Parse,a,`n
				{
					namenum:=EnumVarName(A_LoopField)
					If namenum
						{
							ControlGetPos,x,y,w,h,%A_LoopField%,%title%
							Globals.SetGlobal(namenum "X",x)
							Globals.SetGlobal(namenum "Y",y)
							Globals.SetGlobal(namenum "W",w)
							Globals.SetGlobal(namenum "H",h)
							Globals.SetGlobal(namenum "X2",x+w)
							Globals.SetGlobal(namenum "Y2",y+h)				
						}
				}
			Return a
		}
}
EnumVarName(control){
	name:=InStr(control,"msctls_p")?"MP"
	:InStr(control,"Static")?"S"
	:InStr(control,"Button")?"B"
	:InStr(control,"Edit")?"E"
	:InStr(control,"ListBox")?"LB"
	:InStr(control,"msctls_u")?"UD"
	:InStr(control,"ComboBox")?"CB"
	:InStr(control,"ListView")?"LV"
	:InStr(control,"SysTreeView")?"TV"
	:InStr(control,"SysLink")?"L"
	:InStr(control,"msctls_h")?"H"
	:InStr(control,"SysDate")?"TD"
	:InStr(control,"SysMonthCal")?"MC"
	:InStr(control,"msctls_t")?"SL"
	:InStr(control,"msctls_s")?"SB"
	:InStr(control,"327701")?"AX"
	:InStr(control,"SysTabC")?"T"
	:0
	num:=(name == "MP")?SubStr(control,18)
	:(name == "S")?SubStr(control,7)
	:(name == "B")?SubStr(control,7)
	:(name == "E")?SubStr(control,5)
	:(name == "LB")?SubStr(control,8)
	:(name == "UD")?SubStr(control,16)
	:(name == "CB")?SubStr(control,9)
	:(name == "LV")?SubStr(control,14)
	:(name == "TV")?SubStr(control,14)
	:(name == "L")?SubStr(control,8)
	:(name == "H")?SubStr(control,16)
	:(name == "TD")?SubStr(control,18)
	:(name == "MC")?SubStr(control,14)
	:(name == "SL")?SubStr(control,18)
	:(name == "SB")?SubStr(control,19)
	:(name == "AX")?SubStr(control,5)
	:(name == "T")?SubStr(control,16)
	:0
	Return name num
}
MouseOver(xa,ya,xb,yb)
{
	MouseGetPos, px, py
	isOver := px >= xa AND px <= xb AND py >= ya AND py <= yb
	Return isOver
} 
Class window {
	_x(title){ 						; Get a windows upper left x position relative to the desktop. This applies 
		WinGetPos,x,,,, %title% 	; to next 3 functions; y, width, and height respectively.
		Return x						; title - can be anything that can be passed to WinGetPos
	}									; E.g.: Window Title, ahk_class Shell_TrayWnd, etc...
	_y(title){
		WinGetPos,,y,,, %title%
		Return y
	}
	_w(title){
		WinGetPos,,,w,, %title%
		Return w
	}
	_h(title){
		WinGetPos,,,,h, %title%
		Return h
	}
	_halfw(title){ 				; Get the half width of a window to use in conjunction with screen._cx()
		WinGetPos,,,w,, %title% 	; to perfectly center a window in the desktop. Formula for a windows
		Return w/2 					; center X pos be WindowX:=screen._cx() - window._halfw("Window Title")
	}
	_halfh(title){
		WinGetPos,,,,h, %title%
		Return h/2
	}
	; Window controls class, syntax E.g.:
	; controlXpos:=window.controls._x("Static1","Window Title") 
	; or MsgBox % window.controls._x2("msctls_progress322","Window Title")
	Class controls {
		_x(control,title){ 								; Get a controls X position relative to the desktop.
			ControlGetPos,x,,,,% control,% title		; This applies to the next 5 functions for y, Width,
			Return x										; Height, x2 position (x+w) and y2 for MouseOver 
		}													; function.
		_y(control,title){
			ControlGetPos,,y,,,% control,% title
			Return y
		}
		_w(control,title){
			ControlGetPos,,,w,,% control,% title
			Return w
		}
		_h(control,title){
			ControlGetPos,,,,h,% control,% title
			Return h
		}
		_x2(control,title){
			ControlGetPos,x,,w,,% control,% title
			Return x+w
		}
		_y2(control,title){
			ControlGetPos,,y,,h,% control,% title
			Return y+h
		}
	}
}
; Get the desktops width and height, syntax E.g.:
; screenWidth:=screen._w() or MsgBox % screen._h() 
Class screen {
	_w(){
		SysGet,w,16
		Return w
	}
	_h(){				; 17 gets the hieght minus the taskbar.
		SysGet,h,17	; using _hbar() for full height.
		Return h
	}
	_hbar(){			; 79 gets height plus the taskbar.
		SysGet,h,79
		Return h	
	}
	_cx(){ 						; Screen center X
		Return (screen._w()/2)		
	}
	_cy(){						; Screen center y minus taskbar
		Return (screen._h()/2)		
	}
	_cybar(){						; Screen center y plus taskbar
		Return (screen._hbar()/2)		
	}
}