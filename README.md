## NPS - Folder Backup

NPS - Folder Backup is a small program written in the scripting language AutoHotkey to 
quickly backup any folder on your Windows OS.

## Example Code - Backup Function

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

## Motivation

I created this to quickly backup folders on my computer.

## Installation

Portable program (Plans for installer and portable option).


## Test
I have tested on Windows 10 32 Bit and Windows 7 64 Bit.

## Contributors

Ian Pride @ faithnomoread@yahoo.com - [Lateralus138] @ New Pride Services 

## License

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

	License provided in gpl.txt