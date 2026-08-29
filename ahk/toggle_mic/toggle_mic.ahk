; Toggle Microphone Mute (Left Ctrl + Right Click)
^RButton::{
    deviceName := "HyperX"
    deviceType := "Mic"
	trayDelay := -1300
    found := false
	
    Loop 32
    {
        try {
            deviceGet := SoundGetName(, A_Index)
            
            if InStr(deviceGet, deviceName) && InStr(deviceGet, deviceType)
            {
                SoundSetMute(-1, , A_Index)
                isMuted := SoundGetMute(, A_Index)
                
                if (isMuted) {
					TrayTip deviceGet, "Microphone Muted", "Icon! Mute"
                } else {
					TrayTip deviceGet, "Microphone Active", "Iconi Mute"
                }
				
				SetTimer () => TrayTip(), trayDelay
                found := true
                break 
            }
        }
    }
	
    if (!found) {
        TrayTip deviceName, "Microphone Not Found", "Iconx Mute"
		SetTimer () => TrayTip(), trayDelay
	}
	
	Send "{Esc}"
}