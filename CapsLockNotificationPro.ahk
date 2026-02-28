; ============================================================
; CapsLockNotificationPro.ahk (AutoHotkey v2)
; 功能：大小写 + 输入法状态提示（独立显示）
; - CapsLock：显示 🔒大写 / 🔓小写
; - Shift：显示 中 / 英
; ============================================================

#SingleInstance Force
Persistent

global showDuration := 800
global lastCapsState := GetKeyState("CapsLock", "T")

A_TrayTip := "大小写+输入法提示"

; CapsLock 监听
SetTimer(CheckCapsLock, 30)

; Shift 监听（只显示中/英）
~Shift:: {
    KeyWait("Shift")  ; 等待 Shift 释放
    ime := GetIMEStatus()
    MouseGetPos(&x, &y)
    ToolTip(ime, x + 10, y + 10)
    SetTimer(RemoveTip, 800)
}

return

; ============================================================
; CapsLock 状态检查
; ============================================================
CheckCapsLock() {
    global lastCapsState
    current := GetKeyState("CapsLock", "T")
    if (current != lastCapsState) {
        lastCapsState := current
        ShowCapsStatus(current)
    }
}

; ============================================================
; 只显示大小写状态
; ============================================================
ShowCapsStatus(isCaps) {
    global showDuration
    tip := isCaps ? "🔒 大写" : "🔓 小写"
    MouseGetPos(&x, &y)
    ToolTip(tip, x + 10, y + 10)
    SetTimer(RemoveTip, showDuration)
}

; ============================================================
; 只显示中/英状态
; ============================================================
ShowIMEOnly() {
    global showDuration
    ime := GetIMEStatus()
    if (ime != "") {
        MouseGetPos(&x, &y)
        ToolTip(ime, x + 10, y + 10)
        SetTimer(RemoveTip, showDuration)
    }
}

; ============================================================
; 获取输入法中/英状态（搜狗输入法专用）
; ============================================================
GetIMEStatus() {
    try hWnd := WinExist("A")
    catch
        return ""

    if (!hWnd)
        return ""

    ; 获取默认 IME 窗口
    hIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr", hWnd, "UInt")

    if (!hIMEWnd)
        return ""

    ; 发送 WM_IME_CONTROL 消息获取状态
    ; 0x283 = WM_IME_CONTROL
    ; 0x005 = IMC_GETCONVERSIONSTATUS
    DetectHiddenWindows(true)
    result := SendMessage(0x283, 0x005, 0, , "ahk_id " . hIMEWnd)
    DetectHiddenWindows(false)

    ; result = 1 表示中文模式，0 表示英文模式
    return (result = 1) ? "中" : "英"
}

; ============================================================
; 关闭提示
; ============================================================
RemoveTip() {
    ToolTip()
    SetTimer(RemoveTip, 0)
}
