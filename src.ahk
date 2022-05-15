#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent
#NoTrayIcon

req := ComObjCreate("Msxml2.XMLHTTP")
global players
global qserver
servers := {"<SERVER NAME>": "<GAMETRACKER SERVER URL>", "<SERVER NAME>": "<GAMETRACKER SERVER URL>", "<SERVER NAME>": "<GAMETRACKER SERVER URL>"}
serveraddr := {"<SERVER NAME>": "<SERVER IP>", "<SERVER NAME>": "<SERVER IP>", "<SERVER NAME>": "<SERVER IP>"}
serverplayers := {"<SERVER NAME>": 0, "<SERVER NAME>": 0, "<SERVER NAME>": 0}
threshold := 8 ; how many players should be on the server
SetTimer, loop, 900000 ; loop every 15 mins


Ready() {
    global req
    if (req.readyState != 4)  ; Not done yet.
        return
    if (req.status == 200) ; OK.
        players := SubStr(req.responseText, InStr(req.responseText, "HTML_num_players")+18, 1)
    else
        players := "err"
}

loop:
process, exist, csgo.exe ; if csgo is open, don't check. (you can remove this)
if (!errorlevel) {
    for key, value in servers {
        req.open("GET", value, true)
        req.onreadystatechange := Func("Ready")
        req.send()

        while req.readyState != 4
        sleep 100

        if (key = "SG")
            players -= 1

        serverplayers[key] := players
    }
    for key, value in serverplayers {
        if (value >= threshold) {
            qserver := key
            TrayTip, %value% players are on %key%, Click to join, , 1
            setTimer trackMouse, 4
            et := A_TickCount + 4000
            Sleep, 4000
            HideTrayTip()
            Sleep, 3000
        }
    }
}
return

~LButton::
    if (A_TickCount < et) {
        if (class = "Windows.UI.Core.CoreWindow") {
            serv := serveraddr[qserver]
            Run, steam://connect/%serv%
        }
    }
return

trackMouse:
    MouseGetPos,,, ID
    WinGetClass, class, ahk_id %ID%
    if (A_TickCount > et)
        setTimer trackMouse, off
return

HideTrayTip() {
    TrayTip  ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion,1,3) = "10." {
        Menu Tray, NoIcon
        Sleep 300  ; It may be necessary to adjust this sleep.
        Menu Tray, Icon
    }
}
