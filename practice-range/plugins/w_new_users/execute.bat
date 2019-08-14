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
cmd /c net user /add smiyamoto apple
cmd /c net user /add rwalsh luckynumber
cmd /c net user /add revan qwerty
cmd /c net user /add emclain birthday
cmd /c net user /add jlambert oldtimer
cmd /c net user /add adiaz complain
cmd /c net user /add nscarpino standing
cmd /c net user /add jtretton flagpole
cmd /c net user /add kaziko abc123
cmd /c net user /add bsimpson password
cmd /c net user /add arodriguez swizzl3
cmd /c net user /add rpennysworth password
cmd /c net user /add cweiss coolstuff
cmd /c net user /add t3m4 adobe123
cmd /c net user /add hyamauchi morgan
cmd /c net user /add tprice matt
cmd /c net user /add poliver bonnie
cmd /c net user /add spongebob random
cmd /c net user /add jrubenstein faithful
cmd /c net user /add mblank doot
cmd /c net user Administrator Passwordhotsauce
cmd /c net user user Passwordhotsauce
