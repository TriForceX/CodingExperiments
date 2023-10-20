:: Python Compiler (Windows)
@echo off

:: Enable delayed expansion
setlocal enableDelayedExpansion

:: Set console title
title Python Compiler

:: Build info
:Begin
set py_target=example_file
set py_ext=py
set py_gui=no
echo Python file to build: %py_target%
set /p py_target=Do you want to build another file? (Type its name or press ENTER to skip): 
set /p py_gui=Do you want to build as GUI App? (Type ^"yes^" or Press ENTER to skip): 

:: Check build
if exist "%py_target%.py" (
	:: Check build type
	if /i "%py_gui%" == "yes" (
		set py_ext=pyw
	)
	:: Check previous build
	if exist "%py_target%" (
		echo Removing previous build...
		rd /s /q "%py_target%"
	)
	:: Generate temp file
	if /i "%py_gui%" == "yes" (
		echo Generating temporary file %py_target%.pyw
		copy %py_target%.py %py_target%.pyw > nul
	)
	:: Run build
	if exist "%py_target%.!py_ext!" (
		echo Building %py_target%.!py_ext!
		pyinstaller --clean --onefile %py_target%.!py_ext! --specpath ./%py_target%/spec --distpath ./%py_target%/dist --workpath ./%py_target%/build
	)
	:: Remove temp file
	if /i "%py_gui%" == "yes" (
		echo Removing temporary file...
		del %py_target%.pyw
	)
) else (
	:: Try again
	echo File "%py_target%.py" not found^^!
	pause
	cls
	goto :Begin
)
pause 