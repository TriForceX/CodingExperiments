#Requires AutoHotkey v2.0

; -------- Imports --------
; #include Example1.ahk
; #include Example2.ahk

; -------- Button launch --------
^F1::userLauncher()

; -------- Reload launch --------
for userArg in A_Args {
	if (userArg = "--reload")
		SetTimer userLauncher, -100
		break
}

; -------- Main settings --------
global userWindow := ""
global userStatus := ""
global userEditor := "C:\Program Files\Notepad++\notepad++.exe"
global userMouseLock := true
userProfile := EnvGet("USERPROFILE")
userConfigs := [
	; Menu button
	{
		name: "🚀 Startup Work",
		function: false,
		folders: [
			userProfile . "\Documents",
			userProfile . "\Downloads"
		],
		apps: [
			{
				exe: "C:\Program Files\Mozilla Firefox\firefox.exe",
				params: "https://www.youtube.com https://chatgpt.com https://github.com",
				keyboard: "^2",
				centered: false
			}, 
			{
				exe: userProfile . "\AppData\Local\Discord\Update.exe",
				params: "--processStart Discord.exe",
				keyboard: "#{Down}",
				centered: true
			}, 
			{
				exe: "C:\Program Files\Microsoft Office\root\Office16\OneNote.exe",
				params: false,
				keyboard: false,
				centered: true
			}
		]
	},
	; Menu button
    {
		name: "💻 Jedi Knight Coding",
		function: false,
		folders: [
			userProfile . "\Documents\Code",
			"D:\Backup\Server\JediOutcast\GameData",
			"C:\Program Files (x86)\Steam\steamapps\common\Jedi Outcast\GameData",
			"D:\Backup\Projects\JediOutcast"
		],
		apps: [
			{
				exe: userProfile . "\AppData\Local\SourceTree\SourceTree.exe",
				params: false,
				keyboard: false,
				centered: true
			}
		]
	},
	; Menu button
    {
		name: "🌎 Web Development",
		function: false,
		folders: [
			userProfile . "\Documents\Web",
			"C:\MAMP\bin\php"
		],
		apps: [
			{
				exe: userProfile . "\AppData\Local\SourceTree\SourceTree.exe",
				params: false,
				keyboard: false,
				centered: true
			}, 
			{
				exe: "C:\MAMP\MAMP.exe",
				params: false,
				keyboard: "^2 !{Space}n",
				centered: false
			}
		]
	},
	; Menu button
	{
		name: "🏠 Home Office",
		function: false,
		folders: false,
		apps: [
			{
				exe: "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
				params: "https://www.youtube.com https://chatgpt.com https://gitlab.com",
				keyboard: false,
				centered: false
			}
		]
	},
	; Menu button
	{
		name: "🗡️ JK2 MultiVersion",
		function: false,
		folders: false,
		apps: [
			{
				exe: "C:\Program Files (x86)\Steam\steamapps\common\Jedi Outcast\GameData_JK2MV\jk2mvmp.exe",
				params: "+exec triforce",
				keyboard: false,
				centered: true
			}
		]
	},
	; Menu button
	{
		name: "⚔️ Open Jedi Knight",
		function: false,
		folders: false,
		apps: [
			{
				exe: "C:\Program Files (x86)\Steam\steamapps\common\Jedi Academy\GameData_OpenJK\openjk.x86.exe",
				params: "+exec triforce",
				keyboard: false,
				centered: true
			}
		]
	}
	; Menu button
	; {
	; 	name: "Debug",
	; 	function: false,
	; 	folders: false,
	; 	apps: false
	; }
]

; -------- Main window --------
userLauncher() {
    global userConfigs, userWindow, userMouseLock, userStatus

    ; Modal window
	userWindow := Gui("+AlwaysOnTop -Resize -MaximizeBox", "App Launcher")
	userWindow.SetFont("s10", "Segoe UI")

	guiW := 280
	padX := 10
	contentW := guiW - (padX * 2)
	smallBtnW := 28
	smallBtnGap := 4
	guyY := 15
	
	; Title
	txtTitle := userWindow.AddText("x" padX " y" guyY " w" contentW " Center", "Select Workspace")
	txtTitle.SetFont("s12 Bold", "Segoe UI")
	guyY += 25
	
	; Status
	userStatus := userWindow.AddText("x" padX " y" guyY " w" contentW " Center", ConfigStatus())
	userStatus.SetFont("s8", "Segoe UI")
	guyY += 35

    ; Button list
    for config in userConfigs {
		thisConfig := config
		btn := userWindow.AddButton("x" padX " y" guyY " w" contentW " h40", thisConfig.name)
		btn.SetFont("s10", "Segoe UI")
		btn.OnEvent("Click", SelectConfig.Bind(thisConfig))
		guyY += 50
	}
	guyY += 15
	
	; Check buttons
	btnReloadX := guiW - padX - smallBtnW
	btnEditX := btnReloadX - smallBtnGap - smallBtnW
	btnEmojiX := btnEditX - smallBtnGap - smallBtnW
	
	chkW := btnEmojiX - padX - 8
	chkLock := userWindow.AddCheckBox("x" padX " y" guyY " w" chkW, "Lock mouse on load")
	chkLock.Value := userMouseLock
	chkLock.OnEvent("Click", (ctrl, *) => userMouseLock := ctrl.Value)

	; Emoji
	btnEmoji := userWindow.AddButton("x" btnEmojiX " y" guyY - 2 " w" smallBtnW " h24", "😆")
	btnEmoji.OnEvent("Click", EmojiPanel)
	btnEmoji.OnToolTip := "Emoji Panel"

	; Edit
	btnEdit := userWindow.AddButton("x" btnEditX " y" guyY - 2 " w" smallBtnW " h24", "📝")
	btnEdit.OnEvent("Click", EditScript)
	btnEdit.OnToolTip := "Edit Launcher"

	; Reload
	btnReload := userWindow.AddButton("x" btnReloadX " y" guyY - 2 " w" smallBtnW " h24", "🔄")
	btnReload.OnEvent("Click", ReloadScript)
	btnReload.OnToolTip := "Reload Launcher"

	guyY += 35

    ; Center window
	guiH := guyY
	xPos := (A_ScreenWidth - guiW) // 2
	yPos := (A_ScreenHeight - guiH) // 2
	userWindow.Show("x" xPos " y" yPos " w" guiW " h" guiH)
}

; -------- Emoji panel --------
EmojiPanel(*) {
	global userWindow
	ToolTip
	userWindow.Minimize()
	Sleep 100
	SendEvent "#."
}

; -------- Edit script --------
EditScript(*) {
	global userEditor, userWindow
	userWindow.Minimize()
	if (userEditor != "" && FileExist(userEditor))
		Run '"' userEditor '" "' A_ScriptFullPath '"'
	else
		Run '*Edit "' A_ScriptFullPath '"'
}

; -------- Reload script --------
ReloadScript(*) {
	Run '"' A_AhkPath '" "' A_ScriptFullPath '" --reload'
	ExitApp
}

; -------- Config status --------
ConfigStatus() {
	global userConfigs
	totalApps := 0
	totalFolders := 0
	for config in userConfigs {
		if (config.HasProp("apps") && config.apps)
			totalApps += config.apps.Length
		if (config.HasProp("folders") && config.folders)
			totalFolders += config.folders.Length
	}
	return "Apps: " totalApps " | Folders: " totalFolders
}

; -------- ToolTip on hover --------
OnMessage(WM_MOUSEMOVE  := 0x0200, OnMouseEvent)
OnMessage(WM_MOUSELEAVE := 0x02A3, OnMouseEvent)
OnMouseEvent(wp, lp, msg, hwnd) {
	global userWindow
    if !WinExist("ahk_id " userWindow.Hwnd)
        return
    if (DllCall("GetParent", "Ptr", hwnd, "Ptr") != userWindow.Hwnd)
        return
    static TME_LEAVE := 0x2, TRACKMOUSEEVENT := Buffer(8 + A_PtrSize * 2), onButtonHover := false
    if msg = WM_MOUSEMOVE && !onButtonHover && (obj := GuiCtrlFromHwnd(hwnd)).HasProp('OnToolTip') {
        NumPut('UInt', TRACKMOUSEEVENT.Size,
               'UInt', TME_LEAVE,
               'Ptr', hwnd,
               'Ptr', 10, TRACKMOUSEEVENT)
        DllCall('TrackMouseEvent', 'Ptr', TRACKMOUSEEVENT)
        onButtonHover := true
        ToolTip obj.OnToolTip
    }
    if msg = WM_MOUSELEAVE {
        onButtonHover := false
        ToolTip
    }
}

; -------- Extra mouse lock --------
global BlockMouse := false
#HotIf BlockMouse
LButton::
RButton::
MButton::
XButton1::
XButton2::
WheelUp::
WheelDown::
WheelLeft::
WheelRight::Return
#HotIf

; -------- Select config function --------
SelectConfig(config, *) {
    global userConfigs, userWindow, userMouseLock, BlockMouse
	trayTipDelay := 3000
	userWindow.Destroy()
	
	; Enable mouse lock
	if (userMouseLock)
		BlockInput "MouseMove"
		BlockMouse := true
    
	; Check function (MyFunc.Bind(parm1, param2))
	if (config.HasProp("function") && config.function) {
		config.function.Call()
	}
	
	; Check folders
	if (config.HasProp("folders") && config.folders) {
		folders := config.folders
		
		; Open explorer windows from scratch
		if (config = userConfigs[1]) {
			; Check folder
			if WinExist("ahk_class CabinetWClass") {
				TrayTip "Must close opened folders! Skipping...", config.name, "Iconx Mute"
				Sleep trayTipDelay 
				TrayTip
			}
			; Parse folders
			else {
				firstHwnd := 0
				for index, path in folders {
					before := WinGetList("ahk_class CabinetWClass")

					; Check Documents or Downloads
					if (path = userProfile . "\Documents") {
						Run A_MyDocuments
					}
					else if (path = userProfile . "\Downloads") {
						Run "shell:Downloads"
					}
					; Any other folder
					else {
						Run path
					}

					; Wait for new explorer window
					Loop {
						after := WinGetList("ahk_class CabinetWClass")
						if (after.Length > before.Length)
							break
						Sleep 200
					}

					; Get new hwnd
					newHwnd := 0
					for hwnd in after {
						if !before.Has(hwnd) {
							newHwnd := hwnd
							break
						}
					}

					; Move windows
					if (newHwnd) {
						if (!firstHwnd)
							firstHwnd := newHwnd
						; First window
						if (index = 1) {
							WinMove 212, 290, 823, 712, newHwnd
						}
						; Second window
						else if (index = 2) {
							WinMove 1067, 290, 823, 712, newHwnd
						}
					}
					; Focus first window
					if (firstHwnd) {
						WinActivate firstHwnd
					}
				}
			}
		}
		; Regular tab update
		else 
		{
			; Check folder
			if !WinActive("ahk_class CabinetWClass") {
				TrayTip "Must focus an opened folder! Skipping...", config.name, "Icon! Mute"
				Sleep trayTipDelay 
				TrayTip
			}
			; Parse tabs
			else {
				; Go to first tab
				Send "^1"
				Sleep 300

				; Close tabs at right
				Loop {
					oldTitle := WinGetTitle("A")
					Send "^{Tab}"
					Sleep 400
					newTitle := WinGetTitle("A")
					if (oldTitle = newTitle)
						break
					Send "^w"
					Sleep 500
				}

				; Back to first tab
				Send "^1"
				Sleep 400

				; Open first folder
				Send "^l"
				Sleep 300
				Send "^a"
				Sleep 200
				SendText folders[1]
				Sleep 200
				Send "{Enter}"
				Sleep 900

				; Open remaining folders
				Loop folders.Length - 1 {
					path := folders[A_Index + 1]
					Send "^t"
					Sleep 700
					Send "^l"
					Sleep 300
					Send "^a"
					Sleep 200
					SendText path
					Sleep 200
					Send "{Enter}"
					Sleep 900
				}

				; Back to first tab
				Send "^1"
			}
		}
	}
	
	; Parse apps
	if (config.HasProp("apps") && config.apps) {
		for app in config.apps {
			SplitPath app.exe, &appName, &appDir
			params := app.params
			keyboard := app.keyboard
			centered := app.centered
			
			; Resolve target process
			targetExe := appName
			; Special case (Discord)
			if (InStr(app.exe, "Discord\Update.exe"))
				targetExe := "Discord.exe"
			; Skip if already running
			if ProcessExist(targetExe)
				continue
			; Build command
			runCmd := '"' app.exe '"'
			if (params && params != "")
				runCmd .= " " params
			; Launch application
			Run runCmd, appDir
			; Wait process
			ProcessWait targetExe
			; Wait main window
			hwnd := 0
			stableCount := 0
			lastHwnd := 0
			Loop {
				windowList := WinGetList("ahk_exe " targetExe)
				currentHwnd := 0
				for thisHwnd in windowList {
					thisHwnd := Integer(thisHwnd)
					if !WinExist("ahk_id " thisHwnd)
						continue
					try title := WinGetTitle("ahk_id " thisHwnd)
					catch
						continue
					if (title = "")
						continue
					; Special case (Discord)
					if (targetExe = "Discord.exe" && title = "Discord Updater")
						continue
					; Special case (SourceTree)
					if (targetExe = "SourceTree.exe" && WinGetClass("ahk_id " thisHwnd) = "SplashScreen")
						continue
					if !DllCall("IsWindowVisible", "Ptr", thisHwnd)
						continue
					; Keep newest valid window
					currentHwnd := thisHwnd
				}
				if (currentHwnd) {
					if (currentHwnd = lastHwnd) {
						stableCount++
					} else {
						lastHwnd := currentHwnd
						stableCount := 0
					}
					; One second stable
					if (stableCount >= 4) {
						hwnd := currentHwnd
						break
					}
				}
				Sleep 250
			}
			; Restore if minimized
			if (WinGetMinMax("ahk_id " hwnd) = -1) {
				WinRestore "ahk_id " hwnd
				Sleep 500
			}
			; Wait until window is usable
			Loop {
				try {
					WinGetPos , , &w, &h, "ahk_id " hwnd
				} catch {
					Sleep 250
					continue
				}
				if (w > 0 && h > 0)
					break
				Sleep 250
			}
			; Restore if minimized
			if (WinGetMinMax("ahk_id " hwnd) = -1) {
				WinRestore "ahk_id " hwnd
				Sleep 500
			}
			; Activate window
			Loop {
				WinActivate "ahk_id " hwnd
				if WinActive("ahk_id " hwnd)
					break
				Sleep 200
			}
			Sleep 500
			; Center window
			if (centered) {
				WinGetPos , , &w, &h, "ahk_id " hwnd
				appX := (A_ScreenWidth - w) // 2
				appY := (A_ScreenHeight - h) // 2
				WinMove appX, appY, , , "ahk_id " hwnd
				Sleep 300
			}
			; Special case (Firefox)
			if (keyboard && targetExe = "firefox.exe") {
				Loop {
					try title := WinGetTitle("ahk_id " hwnd)
					catch
						break
					if (title != "Mozilla Firefox")
						break
					Sleep 300
				}
				Sleep 1000
			}
			; Re-activate before keyboard
			Loop {
				WinActivate "ahk_id " hwnd
				if WinActive("ahk_id " hwnd)
					break
				Sleep 100
			}
			; Send keyboard
			if (keyboard) {
				Sleep 300
				SendEvent keyboard
				Sleep 700
			}
			; Continue next app
			Sleep 500
		}
	}
	
	; Disable mouse lock
	if (userMouseLock)
		BlockInput "MouseMoveOff"
		BlockMouse := false

	; Final notification
	TrayTip "Enviroment loaded succesfully!", config.name, "Iconi"
}