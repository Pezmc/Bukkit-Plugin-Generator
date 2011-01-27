@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: Set up our variables.
SET _CWD=%~dp0
SET _OLDPATH=%PATH%
SET PATH=%_CWD%libw\bin
SET _OS=NT

:: Set the bash scripts to be executable.
%PATH%\chmod.exe +x %_CWD%create

:: Finally, run the bash script.
%PATH%\bash.exe %_CWD%create
PAUSE

:: Fix the old variables. (In case
:: someone called this batch file through
:: cmd.exe /K create.bat)
SET PATH=%_OLDPATH%
:: And zero out the unnecessary variables.
SET _OLDPATH=
SET _CWD=
SET _OS=

:: Done.
ENDLOCAL