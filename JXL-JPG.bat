@echo off

SETlocal EnableExtensions
SETlocal EnableDelayedExpansion

TITLE JPG lossless batch converter - By 3DJ

SET InputFormat=JXL

pushd "%~dp0"
IF NOT "%~1"=="" (
	IF EXIST "%~1/*" (
		CD "%~1"
		pushd  "%~1"
		SET "OutputPath=%~1\"
		) ELSE (
		For %%A in ("%~1") do (
			CALL :Convert %%A "%%~dpA%%~nA.jpg"
			PAUSE
			EXIT
			)
		)
	)

ECHO.
ECHO Press any key to convert all the !InputFormat! files in this folder and subfolders
ECHO Output format: JPG lossless
IF DEFINED OutputPath (
	ECHO Output folder: !OutputPath!
	) ELSE (
	ECHO Output folder: JPG\
	)
ECHO Folder structure: Same as input relative path
ECHO.
ECHO - To generate JPG files in the same folder as the input files, 
ECHO close this window and drag the folder/file into the .bat file.
ECHO - Existing JPG files will be skipped, 
ECHO so you can stop and resume batch conversion later if needed.
PAUSE >NUL
ECHO.

FOR /R %%A in (*.*) do (
	IF /I "%%~xA"==".!InputFormat!" (
		SET "OutputPath=%%~dpA"
		IF "%~1"=="" (
			SET "OutputPath=%~dp0JPG\!OutputPath:%~dp0=!"
			IF NOT EXIST "!OutputPath!" (
				MKDIR "!OutputPath!"
				)
			)
		CALL :Convert "%%A" "!OutputPath!%%~nA.jpg"
		)
	)
ECHO Press any key to open the output folder
PAUSE
"!OutputPath!"

:Convert
IF NOT EXIST %2 (
	CALL :Encode %1 %2
	) ELSE (
	For %%F in (%2) do (SET Filesize=%%~zF)
	if !Filesize! EQU 0 (
		ECHO %2 already exists, but seems corrupted/empty. Re-converting...
		CALL :Encode %1 %2
		) ELSE (
		ECHO %2 already exists. Skipping...
		)
	)
EXIT /B

:Encode
ECHO Encoding %2
"%~dp0Converters/djxl.exe" %1 %2
ECHO.
EXIT /B