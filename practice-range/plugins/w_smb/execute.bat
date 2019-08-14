REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
cmd /c net user guest /active:yes
cmd /c reg ADD HKLM\SYSTEM\CurrentControlSet\Control\LSA\ /t REG_DWORD /v RestrictAnonymous /d 0 /f
cmd /c reg ADD HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\ /t REG_MULTI_SZ /v NullSessionShares /d "Public" /f
cmd /c reg ADD HKLM\System\CurrentControlSet\Services\LanManServer\Parameters\ /t REG_DWORD /v RestrictNullSessAccess /d 0 /f 
cmd /c mkdir c:\Public
cmd /c net share Public=C:\Public /grant:Everyone,READ /grant:Guest,READ
cmd /c echo scorebot > c:\Public\ownership.txt
cmd /c ping 127.0.0.1 -n 4 > nul
cmd /c icacls "C:\Public\ownership.txt" /grant Everyone:R /T
cmd /c icacls "C:\Public\ownership.txt" /grant Guest:R /T