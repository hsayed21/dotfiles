@echo off
set "BASH=C:\Program Files\Git\bin\bash.exe"

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "$f='%~f0'; while((Get-Item $f -Force).LinkType -eq 'SymbolicLink'){$t=(Get-Item $f -Force).Target; if([IO.Path]::IsPathRooted($t)){$f=$t}else{$f=[IO.Path]::Combine([IO.Path]::GetDirectoryName($f),$t)}}; [IO.Path]::GetDirectoryName($f)"`) do set "SCRIPT_DIR=%%i"

"%BASH%" "%SCRIPT_DIR%\claude-deepseek.sh" %*
