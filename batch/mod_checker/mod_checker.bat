:: File Modified Checker
@echo off

:: Set console title
title File Modified Checker

:: Target File
:Begin
set file_check=example_file.zip
echo Current file to check: %file_check%
set /p file_check=Do you want to check another file? (Type its name or press ENTER to skip): 
for %%? in ("%file_check%") do set modifiedDate=%%~t?

:: File check
if not exist "%file_check%" (
	:: Try again
	echo File "%file_check%" not found!
	pause
	cls
	goto :Begin
)

:: Modified check
if exist "mod_checker.last" for /f "delims=" %%a in (mod_checker.last) do set lastDate=%%a
if exist "mod_checker.last" (
	if "%modifiedDate%" == "%lastDate%" (
		:: Same version
		goto NoChanges
	) else (
		:: New version
		echo %modifiedDate%> mod_checker.last
		goto NewChanges
		pause
	)
	pause
) else (
	:: First
	echo %modifiedDate%> mod_checker.last
	goto FirstTime
)

:FirstTime
echo New file added! (%modifiedDate%)
pause
exit

:NewChanges
echo New file changes! (%lastDate% to %modifiedDate%)
pause
exit

:NoChanges
echo No changes in the current file.
pause
exit