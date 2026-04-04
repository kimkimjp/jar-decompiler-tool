# JAR Decompiler Tool - PowerShell Version
# Works on Windows, Linux, and macOS with PowerShell Core

param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$JarFile,

    [Parameter()]
    [Alias('o')]
    [string]$OutputDir,

    [Parameter()]
    [Alias('d')]
    [ValidateSet('cfr', 'fernflower', 'procyon')]
    [string]$Decompiler = 'cfr',

    [Parameter()]
    [Alias('k')]
    [switch]$KeepClass,

    [Parameter()]
    [Alias('v')]
    [switch]$Verbose,

    [Parameter()]
    [Alias('h')]
    [switch]$Help
)

# Color functions
function Write-Info { Write-Host "[INFO]" -ForegroundColor Blue -NoNewline; Write-Host " $args" }
function Write-Success { Write-Host "[SUCCESS]" -ForegroundColor Green -NoNewline; Write-Host " $args" }
function Write-Error { Write-Host "[ERROR]" -ForegroundColor Red -NoNewline; Write-Host " $args" }
function Write-Warning { Write-Host "[WARNING]" -ForegroundColor Yellow -NoNewline; Write-Host " $args" }

# Show help
function Show-Help {
    Write-Host @"
Usage: jar-decompiler.ps1 [OPTIONS] <jar_file>

JAR Decompiler Tool - PowerShell Cross-Platform Version

OPTIONS:
  -JarFile <path>      JAR file to decompile
  -OutputDir <dir>     Output directory (default: <jar_name>_src)
  -Decompiler <type>   Decompiler: cfr, fernflower, procyon (default: cfr)
  -KeepClass           Keep .class files after decompilation
  -Verbose             Enable verbose output
  -Help                Show this help message

EXAMPLES:
  .\jar-decompiler.ps1 myapp.jar
  .\jar-decompiler.ps1 -OutputDir output -Decompiler procyon myapp.jar
  .\jar-decompiler.ps1 -Verbose -KeepClass library.jar

CROSS-PLATFORM:
  Windows:  PowerShell 5.1+ or PowerShell Core
  Linux:    PowerShell Core (pwsh)
  macOS:    PowerShell Core (pwsh)
"@
}

# Check for help or no arguments
if ($Help -or -not $JarFile) {
    Show-Help
    exit 0
}

# Check if JAR file exists
if (-not (Test-Path $JarFile)) {
    Write-Error "JAR file not found: $JarFile"
    exit 1
}

# Check Java installation
try {
    $null = java -version 2>&1
} catch {
    Write-Error "Java is not installed or not in PATH"
    Write-Host "Please install Java from: https://adoptium.net/"
    exit 1
}

# Set output directory
if (-not $OutputDir) {
    $OutputDir = [System.IO.Path]::GetFileNameWithoutExtension($JarFile) + "_src"
}

# Get absolute paths
$JarFile = (Resolve-Path $JarFile).Path
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)

# Determine OS and set decompiler directory
if ($IsWindows -or $env:OS -match "Windows") {
    $DecompilerDir = "$env:USERPROFILE\decompiler-tools"
} else {
    $DecompilerDir = "$HOME/decompiler-tools"
}

# Create directories
if (-not (Test-Path $DecompilerDir)) {
    New-Item -ItemType Directory -Path $DecompilerDir -Force | Out-Null
}
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Decompiler URLs
$DecompilerUrls = @{
    'cfr' = @{
        jar = "$DecompilerDir/cfr.jar"
        url = "https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar"
    }
    'fernflower' = @{
        jar = "$DecompilerDir/fernflower.jar"
        url = "https://github.com/fesh0r/fernflower/releases/download/v1.1.1/fernflower-1.1.1.jar"
    }
    'procyon' = @{
        jar = "$DecompilerDir/procyon.jar"
        url = "https://github.com/mstrobel/procyon/releases/download/v0.6.0/procyon-decompiler-0.6.0.jar"
    }
}

$DecompilerInfo = $DecompilerUrls[$Decompiler]
$DecompilerJar = $DecompilerInfo.jar

# Download decompiler if needed
if (-not (Test-Path $DecompilerJar)) {
    Write-Warning "$Decompiler not found. Downloading..."
    try {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            # PowerShell Core
            Invoke-WebRequest -Uri $DecompilerInfo.url -OutFile $DecompilerJar
        } else {
            # Windows PowerShell
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $DecompilerInfo.url -OutFile $DecompilerJar -UseBasicParsing
        }
        Write-Success "$Decompiler downloaded successfully"
    } catch {
        Write-Error "Failed to download $Decompiler"
        Write-Error $_.Exception.Message
        exit 1
    }
}

Write-Info "JAR Decompiler Tool - PowerShell Version"
Write-Info "========================================="
Write-Host ""

# Extract JAR file
Write-Info "Extracting JAR file..."
Push-Location $OutputDir
try {
    # Try using jar command first
    $jarCmd = Get-Command jar -ErrorAction SilentlyContinue
    if ($jarCmd) {
        & jar xf $JarFile 2>$null
    } else {
        # Use .NET for extraction
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($JarFile, $OutputDir)
    }
    Write-Success "JAR file extracted"
} catch {
    Write-Error "Failed to extract JAR file"
    Pop-Location
    exit 1
}
Pop-Location

# Find class files
Write-Info "Finding .class files..."
$ClassFiles = Get-ChildItem -Path $OutputDir -Filter "*.class" -Recurse
$ClassCount = $ClassFiles.Count
Write-Info "Found $ClassCount class files"

# Decompile
Write-Info "Decompiling with $Decompiler..."

switch ($Decompiler) {
    'cfr' {
        $counter = 0
        foreach ($ClassFile in $ClassFiles) {
            $counter++
            if ($Verbose) {
                Write-Host "  Decompiling ($counter/$ClassCount): $($ClassFile.Name)"
            }
            $JavaFile = $ClassFile.FullName -replace '\.class$', '.java'
            $output = & java -jar $DecompilerJar $ClassFile.FullName 2>$null
            $output | Out-File -FilePath $JavaFile -Encoding UTF8
        }
    }

    'procyon' {
        $counter = 0
        foreach ($ClassFile in $ClassFiles) {
            $counter++
            if ($Verbose) {
                Write-Host "  Decompiling ($counter/$ClassCount): $($ClassFile.Name)"
            }
            $JavaFile = $ClassFile.FullName -replace '\.class$', '.java'
            $output = & java -jar $DecompilerJar $ClassFile.FullName 2>$null
            $output | Out-File -FilePath $JavaFile -Encoding UTF8
        }
    }

    'fernflower' {
        $TempDir = Join-Path $OutputDir "fernflower-temp"
        New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
        & java -jar $DecompilerJar -dgs=1 $JarFile $TempDir 2>$null

        $DecompiledJar = Get-ChildItem -Path $TempDir -Filter "*.jar" | Select-Object -First 1
        if ($DecompiledJar) {
            Push-Location $TempDir
            & jar xf $DecompiledJar.FullName 2>$null
            Remove-Item $DecompiledJar.FullName
            Get-ChildItem -Path $TempDir -Filter "*.java" -Recurse | ForEach-Object {
                $RelativePath = $_.FullName.Substring($TempDir.Length + 1)
                $TargetPath = Join-Path $OutputDir $RelativePath
                $TargetDir = Split-Path $TargetPath -Parent
                if (-not (Test-Path $TargetDir)) {
                    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
                }
                Copy-Item $_.FullName $TargetPath -Force
            }
            Pop-Location
            Remove-Item $TempDir -Recurse -Force
        }
    }
}

Write-Success "Decompilation completed"

# Remove class files if requested
if (-not $KeepClass) {
    Write-Info "Removing .class files..."
    Get-ChildItem -Path $OutputDir -Filter "*.class" -Recurse | Remove-Item
    Write-Success ".class files removed"
}

# Count Java files
$JavaFiles = Get-ChildItem -Path $OutputDir -Filter "*.java" -Recurse
$JavaCount = $JavaFiles.Count

# Summary
Write-Host ""
Write-Success "=== Decompilation Summary ==="
Write-Host "  JAR file:        $JarFile"
Write-Host "  Output directory: $OutputDir"
Write-Host "  Decompiler used: $Decompiler"
Write-Host "  Java files created: $JavaCount"
Write-Host ""
Write-Info "You can browse the decompiled source in: $OutputDir"