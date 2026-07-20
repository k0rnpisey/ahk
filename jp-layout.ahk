



; Map 無変換 (Muhenkan) to left click (including click and hold)
SC07B::
    Click, down  ; Press and hold left mouse button
    KeyWait, SC07B  ; Wait until the key is released
    Click, up  ; Release left mouse button
return

; Map 変換 to left click (including click and hold)
;SC079::
;    Click, down  ; Press and hold left mouse button
;    KeyWait, SC079  ; Wait until the key is released
;    Click, up  ; Release left mouse button
;return

SC06F::
    Click, down
    KeyWait, SC06F
    Click, up
return


; Function to resize and center window with specified width percentage
ResizeWindow(widthPercent) {
    ; First restore the window if it's maximized
    WinRestore, A
    
    ; Get the active window's position to determine which monitor it's on
    WinGetPos, WinX, WinY, WinWidth, WinHeight, A
    
    ; Get monitor info for the monitor containing the active window
    SysGet, MonitorCount, MonitorCount
    
    ; Find which monitor contains the window center point
    WinCenterX := WinX + WinWidth // 2
    WinCenterY := WinY + WinHeight // 2
    
    Loop, %MonitorCount% {
        SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
        
        ; Check if window center is within this monitor's bounds
        if (WinCenterX >= MonitorWorkAreaLeft && WinCenterX <= MonitorWorkAreaRight 
            && WinCenterY >= MonitorWorkAreaTop && WinCenterY <= MonitorWorkAreaBottom) {
            
            ; Calculate new dimensions and position for this monitor
            WorkAreaWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
            WorkAreaHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
            
            NewWidth := WorkAreaWidth * widthPercent
            NewHeight := WorkAreaHeight
            NewX := MonitorWorkAreaLeft + (WorkAreaWidth - NewWidth) // 2  ; Center horizontally
            NewY := MonitorWorkAreaTop
            
            ; Move and resize active window
            WinMove, A, , NewX, NewY, NewWidth, NewHeight
            return
        }
    }
    
    ; Fallback: if no monitor found, use primary monitor
    SysGet, MonitorWorkArea, MonitorWorkArea, 1
    WorkAreaWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
    WorkAreaHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
    
    NewWidth := WorkAreaWidth * widthPercent
    NewHeight := WorkAreaHeight
    NewX := MonitorWorkAreaLeft + (WorkAreaWidth - NewWidth) // 2
    NewY := MonitorWorkAreaTop
    
    WinMove, A, , NewX, NewY, NewWidth, NewHeight
}

; Hotkey definitions
+#1::ResizeWindow(0.1)  ; Shift + Win + 5: 50% width
+#2::ResizeWindow(0.2)  ; Shift + Win + 5: 50% width
+#3::ResizeWindow(0.3)  ; Shift + Win + 6: 60% width
+#4::ResizeWindow(0.4)  ; Shift + Win + 7: 70% width
+#5::ResizeWindow(0.5)  ; Shift + Win + 5: 50% width
+#6::ResizeWindow(0.6)  ; Shift + Win + 6: 60% width
+#7::ResizeWindow(0.7)  ; Shift + Win + 7: 70% width
+#8::ResizeWindow(0.8)  ; Shift + Win + 8: 80% width
+#9::ResizeWindow(0.9)  ; Shift + Win + 9: 90% width
+#0::  ; Shift + Win + 0: 3:2 window (matches BenQ RD280U aspect), centered
    WinRestore, A
    GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
    WorkAreaWidth := WorkAreaRight - WorkAreaLeft
    WorkAreaHeight := WorkAreaBottom - WorkAreaTop

    NewWidth := WorkAreaWidth * 0.75
    NewHeight := Floor(NewWidth * 2 / 3)  ; 3:2 aspect ratio

    ; Cap height to screen height if needed
    if (NewHeight > WorkAreaHeight) {
        NewHeight := WorkAreaHeight
        NewWidth := Floor(NewHeight * 3 / 2)
    }

    NewX := WorkAreaLeft + (WorkAreaWidth - NewWidth) // 2
    NewY := WorkAreaTop + (WorkAreaHeight - NewHeight) // 2

    WinMove, A,, NewX, NewY, NewWidth, NewHeight
return


^+#0:: ; Ctrl + Shift + Win + 0 : apply 3:2 size to ALL open windows, centered
    GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
    WorkAreaWidth := WorkAreaRight - WorkAreaLeft
    WorkAreaHeight := WorkAreaBottom - WorkAreaTop

    NewWidth := WorkAreaWidth * 0.75
    NewHeight := Floor(NewWidth * 2 / 3)  ; 3:2 aspect ratio

    if (NewHeight > WorkAreaHeight) {
        NewHeight := WorkAreaHeight
        NewWidth := Floor(NewHeight * 3 / 2)
    }

    PosX := WorkAreaLeft + (WorkAreaWidth - NewWidth) // 2
    PosY := WorkAreaTop + (WorkAreaHeight - NewHeight) // 2

    WinGet, WindowList, List
    Loop, %WindowList%
    {
        WinID := WindowList%A_Index%
        WinGetTitle, Title, ahk_id %WinID%
        WinGet, Style, Style, ahk_id %WinID%

        if (Title = "" || Title = "Program Manager")
            continue
        if !(Style & 0x10000000)  ; WS_VISIBLE
            continue
        if !(Style & 0x00C00000)  ; WS_CAPTION
            continue

        WinGet, MinMax, MinMax, ahk_id %WinID%
        if (MinMax = -1)
            continue
        if (MinMax = 1)
            WinRestore, ahk_id %WinID%

        WinMove, ahk_id %WinID%,, PosX, PosY, NewWidth, NewHeight
    }
return


+#-:: ; Shift + Win + - : ~24" window width
GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
WorkAreaWidth := WorkAreaRight - WorkAreaLeft
WorkAreaHeight := WorkAreaBottom - WorkAreaTop

WindowWidth := WorkAreaWidth * 0.86   ; ~24" width
WindowHeight := WorkAreaHeight * 0.86  ; Maintain aspect ratio

PosX := WorkAreaLeft + (WorkAreaWidth - WindowWidth) / 2
PosY := Max(WorkAreaTop + 1, WorkAreaBottom - WindowHeight)

WinMove, A,, PosX, PosY, WindowWidth, WindowHeight
return


^+#-:: ; Ctrl + Shift + Win + - : apply ~24" size to ALL open windows
GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
WorkAreaWidth := WorkAreaRight - WorkAreaLeft
WorkAreaHeight := WorkAreaBottom - WorkAreaTop

WindowWidth := WorkAreaWidth * 0.86
WindowHeight := WorkAreaHeight * 0.86
PosX := WorkAreaLeft + (WorkAreaWidth - WindowWidth) / 2
PosY := WorkAreaTop + (WorkAreaHeight - WindowHeight) / 2  ; center vertically

WinGet, WindowList, List  ; get all top-level windows
Loop, %WindowList%
{
    WinID := WindowList%A_Index%
    WinGetTitle, Title, ahk_id %WinID%
    WinGet, Style, Style, ahk_id %WinID%

    ; Skip untitled windows and non-visible/tool windows
    if (Title = "" || Title = "Program Manager")
        continue
    if !(Style & 0x10000000)  ; WS_VISIBLE
        continue
    if !(Style & 0x00C00000)  ; WS_CAPTION (skip borderless/system windows)
        continue

    ; Skip minimized windows — only act on windows already visible on screen
    WinGet, MinMax, MinMax, ahk_id %WinID%
    if (MinMax = -1)
        continue
    if (MinMax = 1)  ; restore maximized windows so they can be resized
        WinRestore, ahk_id %WinID%

    WinMove, ahk_id %WinID%,, PosX, PosY, WindowWidth, WindowHeight
}
return


; Normal movement with Win + Arrow (100 pixels)
#Left::
    WinGetPos, x, y,,, A
    WinMove, A,, x-100, y
return

#Right::
    WinGetPos, x, y,,, A
    WinMove, A,, x+100, y
return

#Up::
    WinGetPos, x, y,,, A
    WinMove, A,, x, y-100
return

#Down::
    WinGetPos, x, y,,, A
    WinMove, A,, x, y+100
return

; Large movement with Shift + Win + Arrow (300 pixels)
+#Left::
    WinGetPos, x, y,,, A
    WinMove, A,, x-300, y
return

+#Right::
    WinGetPos, x, y,,, A
    WinMove, A,, x+300, y
return


; Alt + Win + Arrow to resize active window
^#Left::
WinGetPos,,, Width, Height, A
WinMove, A, , , , Width-100, Height
return

^#Right::
WinGetPos,,, Width, Height, A
WinMove, A, , , , Width+100, Height
return

^#Up::
WinGetPos,,, Width, Height, A
WinMove, A, , , , Width, Height-100
return

^#Down::
WinGetPos,,, Width, Height, A
WinMove, A, , , , Width, Height+100
return



; Function to get the work area of the monitor containing the active window
GetActiveMonitorWorkArea(ByRef WorkAreaLeft, ByRef WorkAreaTop, ByRef WorkAreaRight, ByRef WorkAreaBottom) {
    ; Get the active window's position to determine which monitor it's on
    WinGetPos, WinX, WinY, WinWidth, WinHeight, A
    
    ; Get monitor count
    SysGet, MonitorCount, MonitorCount
    
    ; Find which monitor contains the window center point
    WinCenterX := WinX + WinWidth // 2
    WinCenterY := WinY + WinHeight // 2
    
    Loop, %MonitorCount% {
        SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
        
        ; Check if window center is within this monitor's bounds
        if (WinCenterX >= MonitorWorkAreaLeft && WinCenterX <= MonitorWorkAreaRight 
            && WinCenterY >= MonitorWorkAreaTop && WinCenterY <= MonitorWorkAreaBottom) {
            
            WorkAreaLeft := MonitorWorkAreaLeft
            WorkAreaTop := MonitorWorkAreaTop
            WorkAreaRight := MonitorWorkAreaRight
            WorkAreaBottom := MonitorWorkAreaBottom
            return
        }
    }
    
    ; Fallback: if no monitor found, use primary monitor
    SysGet, MonitorWorkArea, MonitorWorkArea, 1
    WorkAreaLeft := MonitorWorkAreaLeft
    WorkAreaTop := MonitorWorkAreaTop
    WorkAreaRight := MonitorWorkAreaRight
    WorkAreaBottom := MonitorWorkAreaBottom
}

^!c:: ; Ctrl + Alt + C to center the active window without resizing
WinGetPos, , , CurrentWidth, CurrentHeight, A  ; Get current window dimensions
GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
WorkAreaWidth := WorkAreaRight - WorkAreaLeft
WorkAreaHeight := WorkAreaBottom - WorkAreaTop

; Calculate center position based on current window size
NewX := WorkAreaLeft + (WorkAreaWidth - CurrentWidth) // 2   ; Center horizontally
NewY := WorkAreaTop + (WorkAreaHeight - CurrentHeight) // 2  ; Center vertically

WinMove, A, , NewX, NewY, CurrentWidth, CurrentHeight
return

^!j:: ; Ctrl + Alt + J: 30% width full height to the left
GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
WorkAreaWidth := WorkAreaRight - WorkAreaLeft
WorkAreaHeight := WorkAreaBottom - WorkAreaTop

NewWidth := WorkAreaWidth * 0.3     ; 30% of work area width
NewHeight := WorkAreaHeight         ; Full height
NewX := WorkAreaLeft                ; Left edge
NewY := WorkAreaTop                 ; Top edge

WinMove, A, , NewX, NewY, NewWidth, NewHeight
return

^!k:: ; Ctrl + Alt + K: 40% width full height to the center
GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
WorkAreaWidth := WorkAreaRight - WorkAreaLeft
WorkAreaHeight := WorkAreaBottom - WorkAreaTop

NewWidth := WorkAreaWidth * 0.4     ; 40% of work area width
NewHeight := WorkAreaHeight         ; Full height
NewX := WorkAreaLeft + (WorkAreaWidth - NewWidth) // 2  ; Center horizontally
NewY := WorkAreaTop                 ; Top edge

WinMove, A, , NewX, NewY, NewWidth, NewHeight
return

^!l:: ; Ctrl + Alt + L: 30% width full height to the right
GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
WorkAreaWidth := WorkAreaRight - WorkAreaLeft
WorkAreaHeight := WorkAreaBottom - WorkAreaTop

NewWidth := WorkAreaWidth * 0.3     ; 30% of work area width
NewHeight := WorkAreaHeight         ; Full height
NewX := WorkAreaLeft + WorkAreaWidth - NewWidth  ; Right edge
NewY := WorkAreaTop                 ; Top edge

WinMove, A, , NewX, NewY, NewWidth, NewHeight
return




ResizeWindowBox(percent) {
    WinRestore, A
    GetActiveMonitorWorkArea(Left, Top, Right, Bottom)
    W := Right - Left, H := Bottom - Top
    NewW := Floor(W * percent), NewH := Floor(H * percent)
    X := Left + (W - NewW) // 2, Y := Top + (H - NewH) // 2
    WinMove, A,, X, Y, NewW, NewH
}

; 15" Window (10:9 aspect ratio)
; Shift + Win + ^ : Resize window to approximately 15" with 10:9 aspect ratio,
; 25% right margin, bottom aligned
+#^::
    WinRestore, A
    GetActiveMonitorWorkArea(WorkAreaLeft, WorkAreaTop, WorkAreaRight, WorkAreaBottom)
    WorkAreaWidth := WorkAreaRight - WorkAreaLeft
    WorkAreaHeight := WorkAreaBottom - WorkAreaTop

    NewWidth := WorkAreaWidth * 0.75
    NewHeight := Floor(NewWidth * 9 / 10)  ; 10:9 aspect ratio

    ; Cap height to screen height if needed
    if (NewHeight > WorkAreaHeight) {
        NewHeight := WorkAreaHeight
        NewWidth := Floor(NewHeight * 10 / 9)
    }

    ; 25% from right
    NewX := WorkAreaRight - (WorkAreaWidth * 0.15) - NewWidth
    NewY := WorkAreaTop + WorkAreaHeight - NewHeight  ; bottom aligned

    WinMove, A,, NewX, NewY, NewWidth, NewHeight
return


;; This shortcut is remapped because Win + Arrow snaps windows by default, conflicting with our pane move.
#!Left::Send #{Left}
#!Right::Send #{Right}

; Ctrl + Shift + Win + Left/Right to switch between virtual desktops
^+#Left::Send ^#{Left}
^+#Right::Send ^#{Right}

; Remap Insert to PageUp
Insert::PgUp

; Remap Delete to PageDown
Delete::PgDn



; Left or Right Ctrl as Fn modifier
>^F10::Send,{Media_Play_Pause}
<^F10::Send,{Media_Play_Pause}
>^F11::Send,{Volume_Down}
<^F11::Send,{Volume_Down}
>^F12::Send,{Volume_Up}
<^F12::Send,{Volume_Up}




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Map Print Screen to Home
;PrintScreen::Home

; Map Pause/Break to End
;Pause::End

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; JP Layout Navigation Key Mappings
; Author: Custom mapping for Japanese keyboard layout
; Left Win + navigation keys for Home/End/PageUp/PageDown

; Left Win + < to Home
LWin & <::Send, {Home}

; Left Win + > to End  
LWin & >::Send, {End}

; Left Win + \ to Page Down
LWin & SC073::Send, {PgDn}

; Left Win + / to Page Up
LWin & /::Send, {PgUp}

; Use Ctrl+Up/Down for smooth scrolling in Chrome
#If WinActive("ahk_exe chrome.exe")
    ^Up::Send, {WheelUp 3}     ; Smooth scroll up
    ^Down::Send, {WheelDown 3} ; Smooth scroll down
#If