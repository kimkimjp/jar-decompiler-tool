@echo off
setlocal

REM Installation script for Java decompiler tools - Windows version
REM Downloads CFR, Fernflower, and Procyon decompilers

echo [INFO] Java Decompiler Tools Installer - Windows
echo [INFO] ==========================================
echo.

REM Check Java installation
java -version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Java is not installed or not in PATH
    echo.
    echo Please install Java from one of these sources:
    echo   - Oracle JDK: https://www.oracle.com/java/technologies/downloads/
    echo   - OpenJDK: https://adoptium.net/
    echo   - Amazon Corretto: https://aws.amazon.com/corretto/
    echo.
    echo After installation, make sure Java is in your PATH
    pause
    exit /b 1
)

echo [SUCCESS] Java is installed
for /f "tokens=3" %%i in ('java -version 2^>^&1 ^| findstr /i version') do echo   Version: %%i
echo.

REM Create installation directory
set INSTALL_DIR=%USERPROFILE%\decompiler-tools
echo [INFO] Installation directory: %INSTALL_DIR%
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Download CFR
echo [INFO] Downloading CFR (Class File Reader)...
if exist "%INSTALL_DIR%\cfr.jar" (
    echo [WARNING] CFR already exists, skipping...
) else (
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar' -OutFile '%INSTALL_DIR%\cfr.jar'"
    if exist "%INSTALL_DIR%\cfr.jar" (
        echo [SUCCESS] CFR downloaded successfully
    ) else (
        echo [ERROR] Failed to download CFR
    )
)

REM Download Fernflower
echo [INFO] Downloading Fernflower...
if exist "%INSTALL_DIR%\fernflower.jar" (
    echo [WARNING] Fernflower already exists, skipping...
) else (
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/fesh0r/fernflower/releases/download/v1.1.1/fernflower-1.1.1.jar' -OutFile '%INSTALL_DIR%\fernflower.jar'"
    if exist "%INSTALL_DIR%\fernflower.jar" (
        echo [SUCCESS] Fernflower downloaded successfully
    ) else (
        echo [ERROR] Failed to download Fernflower
    )
)

REM Download Procyon
echo [INFO] Downloading Procyon...
if exist "%INSTALL_DIR%\procyon.jar" (
    echo [WARNING] Procyon already exists, skipping...
) else (
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/mstrobel/procyon/releases/download/v0.6.0/procyon-decompiler-0.6.0.jar' -OutFile '%INSTALL_DIR%\procyon.jar'"
    if exist "%INSTALL_DIR%\procyon.jar" (
        echo [SUCCESS] Procyon downloaded successfully
    ) else (
        echo [ERROR] Failed to download Procyon
    )
)

echo.
echo [SUCCESS] === Installation Complete ===
echo.
echo [INFO] Decompiler tools installed in: %INSTALL_DIR%
echo.
echo [INFO] Installed tools:
echo   - CFR (cfr.jar)
echo   - Fernflower (fernflower.jar)
echo   - Procyon (procyon.jar)
echo.
echo [INFO] You can now use jar-decompiler.bat to decompile JAR files
echo [INFO] Example: jar-decompiler.bat myapp.jar
echo.
pause