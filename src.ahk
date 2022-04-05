req := ComObjCreate("Msxml2.XMLHTTP")
global players
servers := {"SG": "https://www.gametracker.com/server_info/mg.steam-gamers.net:27015/", "EGO": "https://www.gametracker.com/server_info/mg.csgo.edgegamers.cc:27015/"}

for key, value in servers {

    req.open("GET", value, true)
    req.onreadystatechange := Func("Ready")
    req.send()

    while req.readyState != 4
    sleep 100

    out .= key . ": " . players . "`n"
}
MsgBox, , , %out%, 2
ExitApp







#Persistent
Ready() {
    global req
    if (req.readyState != 4)  ; Not done yet.
        return
    if (req.status == 200) ; OK.
        players := SubStr(req.responseText, InStr(req.responseText, "HTML_num_players")+18, 1)
    else
        players := "err"
}

