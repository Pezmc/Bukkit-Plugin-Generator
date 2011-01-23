@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: Set up our variables.
SET _CWD=%~dp0
SET UNIXROOT=%_CWD%libexec
SET HOME=%UNIXROOT%
SET _OLDPATH=%PATH%
SET _OLDUSERNAME=%USERNAME%
SET PATH=%UNIXROOT%
SET _OS=NT

:: Set the bash script to be executable.
%PATH%\chmod.exe +x %_CWD%create

:: Ignore below. I originally had the idea to call
:: cmd.exe from the bash file, but that didn't work,
:: and I realized I can run a batch file from our 
:: bash file.
REM IF EXIST %SystemRoot%\system32\cmd.exe GOTO CmdExists
REM :: No cmd.exe? Too bad.
REM SET _CMD=NULL
SET _CMD=NULL
IF EXIST %_CWD%libexec GOTO CmdsExist
GOTO PostCmd

:CmdsExist
:: Again, ignore below.
REM :: Just in case the client's system32 folder is named
REM :: System32, we need to get the exact string, because
REM :: bash's filesystem is case-sensitive.
REM PUSHD %SystemRoot%\system32
REM SET _SYS32=%CD:~-8%
REM POPD
REM SET _CMD=%SystemDrive%\\%SystemRoot:~3%\\%_SYS32%\\cmd.exe
REM SET _CMD=%SystemRoot%\%_SYS32%\cmd.exe /C CLS
REM SET _SYS=
IF EXIST %UNIXROOT%\cls.bat SET _CMD=%UNIXROOT%\cls.bat
GOTO PostCmd

:PostCmd
:: Finally, run the bash script.
%UNIXROOT%\bash.exe %_CWD%create
PAUSE

:: Fix the old variables. (In case
:: someone called this batch file through
:: cmd.exe /K create.bat)
SET PATH=%_OLDPATH%
SET USERNAME=%_OLDUSERNAME%

:: And zero out the unnecessary variables.
SET _OLDPATH=
SET _OLDUSERNAME=
SET _CWD=
SET HOME=
SET _OS=
SET _CMD=

:: Done.
ENDLOCAL