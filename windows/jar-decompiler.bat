@echo off
setlocal enabledelayedexpansion

REM JAR Decompiler Tool for Windows
REM Extracts and decompiles JAR files to Java source code

REM Default values
set DECOMPILER=cfr
set OUTPUT_DIR=
set KEEP_CLASS=false
set VERBOSE=false
set JAR_FILE=
set SCRIPT_DIR=%~dp0

REM Parse arguments
:parse_args
if "%~1"=="" goto :check_jar
if /i "%~1"=="-h" goto :show_help
if /i "%~1"=="--help" goto :show_help
if /i "%~1"=="-o" (
    set OUTPUT_DIR=%~2
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--output" (
    set OUTPUT_DIR=%~2
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-d" (
    set DECOMPILER=%~2
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--decompiler" (
    set DECOMPILER=%~2
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-k" (
    set KEEP_CLASS=true
    shift
    goto :parse_args
)
if /i "%~1"=="--keep-class" (
    set KEEP_CLASS=true
    shift
    goto :parse_args
)
if /i "%~1"=="-v" (
    set VERBOSE=true
    shift
    goto :parse_args
)
if /i "%~1"=="--verbose" (
    set VERBOSE=true
    shift
    goto :parse_args
)

REM If not an option, it's the JAR file
set JAR_FILE=%~1
shift
goto :parse_args

:check_jar
if "%JAR_FILE%"=="" (
    echo [ERROR] No JAR file specified
    call :show_help
    exit /b 1
)

if not exist "%JAR_FILE%" (
    echo [ERROR] JAR file not found: %JAR_FILE%
    exit /b 1
)

REM Set output directory if not specified
if "%OUTPUT_DIR%"=="" (
    for %%i in ("%JAR_FILE%") do set OUTPUT_DIR=%%~ni_src
)

REM Check Java installation
java -version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Java is not installed or not in PATH
    echo Please install Java and try again
    exit /b 1
)

echo [INFO] JAR Decompiler Tool - Windows Version
echo [INFO] =====================================
echo.

REM Create output directory
echo [INFO] Creating output directory: %OUTPUT_DIR%
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Get absolute paths
for %%i in ("%JAR_FILE%") do set JAR_FILE=%%~fi
for %%i in ("%OUTPUT_DIR%") do set OUTPUT_DIR=%%~fi

REM Set decompiler path
set DECOMPILER_DIR=%USERPROFILE%\decompiler-tools
if not exist "%DECOMPILER_DIR%" mkdir "%DECOMPILER_DIR%"

REM Download decompiler if needed
if /i "%DECOMPILER%"=="cfr" (
    set DECOMPILER_JAR=%DECOMPILER_DIR%\cfr.jar
    set DECOMPILER_URL=https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar
)
if /i "%DECOMPILER%"=="procyon" (
    set DECOMPILER_JAR=%DECOMPILER_DIR%\procyon.jar
    set DECOMPILER_URL=https://github.com/mstrobel/procyon/releases/download/v0.6.0/procyon-decompiler-0.6.0.jar
)
if /i "%DECOMPILER%"=="fernflower" (
    set DECOMPILER_JAR=%DECOMPILER_DIR%\fernflower.jar
    set DECOMPILER_URL=https://github.com/fesh0r/fernflower/releases/download/v1.1.1/fernflower-1.1.1.jar
)

if not exist "!DECOMPILER_JAR!" (
    echo [WARNING] %DECOMPILER% not found. Downloading...
    powershell -Command "Invoke-WebRequest -Uri '!DECOMPILER_URL!' -OutFile '!DECOMPILER_JAR!'"
    if errorlevel 1 (
        echo [ERROR] Failed to download %DECOMPILER%
        exit /b 1
    )
    echo [SUCCESS] %DECOMPILER% downloaded
)

REM Extract JAR file
echo [INFO] Extracting JAR file...
cd /d "%OUTPUT_DIR%"
jar xf "%JAR_FILE%" 2>nul || (
    echo [INFO] jar command not found, trying PowerShell...
    powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%JAR_FILE%', '%OUTPUT_DIR%')"
)
echo [SUCCESS] JAR file extracted

REM Count class files
echo [INFO] Finding .class files...
set CLASS_COUNT=0
for /r "%OUTPUT_DIR%" %%f in (*.class) do set /a CLASS_COUNT+=1
echo [INFO] Found %CLASS_COUNT% class files

REM Decompile based on selected decompiler
echo [INFO] Decompiling with %DECOMPILER%...

if /i "%DECOMPILER%"=="cfr" (
    for /r "%OUTPUT_DIR%" %%f in (*.class) do (
        set CLASS_FILE=%%f
        set JAVA_FILE=%%~dpnf.java
        if "%VERBOSE%"=="true" echo   Decompiling: %%~nxf
        java -jar "!DECOMPILER_JAR!" "!CLASS_FILE!" > "!JAVA_FILE!" 2>nul
    )
)

if /i "%DECOMPILER%"=="procyon" (
    for /r "%OUTPUT_DIR%" %%f in (*.class) do (
        set CLASS_FILE=%%f
        set JAVA_FILE=%%~dpnf.java
        if "%VERBOSE%"=="true" echo   Decompiling: %%~nxf
        java -jar "!DECOMPILER_JAR!" "!CLASS_FILE!" > "!JAVA_FILE!" 2>nul
    )
)

if /i "%DECOMPILER%"=="fernflower" (
    java -jar "!DECOMPILER_JAR!" -dgs=1 "%JAR_FILE%" "%OUTPUT_DIR%\temp" 2>nul
    if exist "%OUTPUT_DIR%\temp\%~nx1" (
        cd /d "%OUTPUT_DIR%\temp"
        jar xf "%~nx1" 2>nul
        del "%~nx1"
        xcopy /s /y *.java ".." >nul
        cd /d "%OUTPUT_DIR%"
        rd /s /q temp
    )
)

echo [SUCCESS] Decompilation completed

REM Remove class files if requested
if "%KEEP_CLASS%"=="false" (
    echo [INFO] Removing .class files...
    for /r "%OUTPUT_DIR%" %%f in (*.class) do del "%%f"
    echo [SUCCESS] .class files removed
)

REM Count Java files
set JAVA_COUNT=0
for /r "%OUTPUT_DIR%" %%f in (*.java) do set /a JAVA_COUNT+=1

REM Summary
echo.
echo [SUCCESS] === Decompilation Summary ===
echo   JAR file:        %JAR_FILE%
echo   Output directory: %OUTPUT_DIR%
echo   Decompiler used: %DECOMPILER%
echo   Java files created: %JAVA_COUNT%
echo.
echo [INFO] You can browse the decompiled source in: %OUTPUT_DIR%

exit /b 0

:show_help
echo Usage: jar-decompiler.bat [OPTIONS] ^<jar_file^>
echo.
echo JAR Decompiler Tool - Windows Version
echo.
echo OPTIONS:
echo   -o, --output ^<dir^>      Output directory (default: ^<jar_name^>_src)
echo   -d, --decompiler ^<type^> Decompiler: cfr, fernflower, procyon (default: cfr)
echo   -k, --keep-class        Keep .class files after decompilation
echo   -v, --verbose           Enable verbose output
echo   -h, --help              Show this help message
echo.
echo EXAMPLES:
echo   jar-decompiler.bat myapp.jar
echo   jar-decompiler.bat -o output_dir -d procyon myapp.jar
echo   jar-decompiler.bat -v -k library.jar
echo.
exit /b 0