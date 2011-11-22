#$code = "5D785-AD029-BA701-719F1-D9529-C32CE"
$code = $Cmdline[1]
$serial = ''

FileDelete("C:\dg_serial.txt")

Run("C:\dg_keygen.exe")
$window = 'DesAcc multikeygen (C) 2005 by Team Linezero'

sleep(100)

#comments-start
WinSetOnTop($window, "", 1)
WinActivate($window)


while 1
	if WinActive($window) Then
	  ExitLoop
  Else
	  Run(@WindowsDir & '\System32\tscon.exe 0 /dest:console')
	  Run(@WindowsDir & '\System32\tscon.exe 1 /dest:console')
		  	  Run(@WindowsDir & '\System32\tscon.exe 2 /dest:console')
			  	  Run(@WindowsDir & '\System32\tscon.exe 3 /dest:console')
      WinActivate($window)
	  WinSetOnTop($window, "", 1)
  EndIf
  sleep(10)
WEnd


WinWaitActive($window)
#comments-end

sleep(500)
ControlClick($window, "", "[CLASS:TEdit; INSTANCE:2]")
ControlSend($window, "", "[CLASS:TEdit; INSTANCE:2]", "{BS 35}")
ControlSend($window, "", "[CLASS:TEdit; INSTANCE:2]", "{DEL 35}")
ControlSend($window, "", "[CLASS:TEdit; INSTANCE:2]", $code)
ControlSend($window, "", "[CLASS:TBitBtn; INSTANCE:1]", "!G")
#Send("{BS 35}")
#Send("{DEL 35}")
#Send($code)
#Send("!G")

sleep(500)
$Text=ControlGetText("[CLASS:TForm1]","","[CLASSNN:TEdit1]")
$Value=StringSplit($Text,@CRLF)
For $i=1 To $Value[0]
    If StringRegExp($Value[$i],"[0-9][^:alpha:]") Then
        $serial = $Value[$i]
    EndIf
Next

WinClose($window)

$file = FileOpen("C:\dg_serial.txt", 1)

FileWrite($file, $serial)
FileClose($file)

#comments-start
$window = "Untitled - Notepad"

Run("notepad.exe")
WinWaitActive($window)
Send($serial)
WinClose($window)

#WinWaitActive("Notepad", "Do you want to save")
Send("!Y")

sleep(500)
ControlClick($window, "", "[CLASS:Edit; INSTANCE:1]")
Send("{BS 35}")
Send("{DEL 35}")
Send("C:\dg_serial.txt")

Send("!S")
#comments-end