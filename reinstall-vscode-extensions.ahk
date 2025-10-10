#Requires AutoHotkey >=2.0-

#SingleInstance Off
#NoTrayIcon ;Suggested
#Include _setup\Classes\SpecializedHandlers.ahk

; Re-Install VS Code extensions
VSCodeExtensionsManager.ReInstallExtensions()
Pause()
