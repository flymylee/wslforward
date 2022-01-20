@echo off
SetLocal EnableDelayedExpansion


:: Global variables with default values
:-------------------------------------
REM  --> Set variables as your envirionment
SET _Distro=
SET _Username=
SET _Port_Ingress=
SET _Port_Egress=%_Port_Ingress%
SET _Intranet_Address=
FOR /F "tokens=*" %%g IN ('wsl -d %_Distro% -u %_Username% bash -c "ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1"') do (SET _WSL_IP=%%g)
FOR /F "tokens=3 delims=: " %%g IN ('netsh interface portproxy show v4tov4 ^| findstr 0.0.0.0') do (SET _OLD_IP=%%g)

@REM REM  --> @REM is the codes for debugging
@REM :-------------------------------------
@REM :Usage
@REM   ECHO Update WSL Port Forward
@REM   ECHO wslforward.cmd [-d ^<Distro^>] [-u ^<Username^>] [-s SOURCE_PORT] [-p DEST_PORT]
@REM :-------------------------------------

:: Check for envirionment
:-------------------------------------
:IsIpChanged
  IF '%_WSL_IP%' EQU '%_OLD_IP%' (
    ECHO There is No IP change.
    GoTo :CLEAR_TEMP
  )

:Main
REM  --> Check for existing OpenSSL
>nul 2>&1 netsh.exe interface portproxy set v4tov4 protocol=tcp listenport=%_Port_Ingress% listenaddress=0.0.0.0 connectport=%_Port_Egress% connectaddress=%_WSL_IP%
for %%I IN (%*) DO (
  >nul 2>&1 netsh.exe interface portproxy set v4tov4 protocol=tcp listenport=%%I listenaddress=%_Intranet_Address% connectport=%%I connectaddress=%_WSL_IP%
)

REM  --> Check for permissions
IF DEFINED ProgramFiles(x86) IF /I "%PROCESSOR_ARCHITECTURE%" EQU "x86" (
  >nul 2>&1 "%SystemRoot%\SysWOW64\cacls.exe" "%SystemRoot%\SysWOW64\config\SYSTEM"
) ELSE (
  >nul 2>&1 "%SystemRoot%\System32\cacls.exe" "%SystemRoot%\System32\config\SYSTEM"
)

REM --> If error flag set, you do not have admin.
IF '%ErrorLevel%' NEQ '0' (
  echo Requesting administrative privileges...
  GoTo :UACPrompt
) ELSE (
  GoTo :gotAdmin
)

GoTo :CLEAR_TEMP

:UACPrompt
  SET Params= %*
  echo Set UAC = CreateObject^("Shell.Application"^) > "%TEMP%\GetAdmin.vbs"
  echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %Params:"=""%", "", "RunAs", 1 >> "%TEMP%\GetAdmin.vbs"
  SET Params=

  "%TEMP%\GetAdmin.vbs"
  del "%TEMP%\GetAdmin.vbs"
  EXIT /B

:gotAdmin
  PUSHD "%CD%"
  CD /D "%~dp0"
:--------------------------------------


:CLEAR_TEMP
REM  --> Clear local variables, and close this script
EndLocal
:--------------------------------------