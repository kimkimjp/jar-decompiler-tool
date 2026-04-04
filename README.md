# JAR Decompiler Tool

A comprehensive JAR file decompiler tool with both Bash and Common Lisp implementations.

## Overview

This tool extracts and decompiles JAR files to Java source code, supporting multiple decompiler engines and providing implementations for Windows, Linux, and macOS.

## Features

- 🔧 **Multiple Decompiler Support**: CFR, Fernflower, Procyon
- 📦 **Preserves Package Structure**: Maintains original Java package hierarchy
- 💻 **Cross-Platform**: Windows, Linux, macOS support
- 🚀 **Multiple Implementations**: Bash, PowerShell, Batch, Lisp
- 🎯 **Java 8+ Support**: Handles modern Java features (lambdas, streams, etc.)
- 🔍 **Verbose Mode**: Detailed decompilation progress
- 📁 **Flexible Output**: Custom output directory support

## Quick Start

### Windows

```cmd
cd windows
install-decompilers.bat
jar-decompiler.bat myapp.jar
```

### Linux/macOS

```bash
cd bash
./install-decompilers.sh
./jar-decompiler.sh myapp.jar
```

### PowerShell (Cross-platform)

```powershell
cd windows
.\jar-decompiler.ps1 myapp.jar
```

## Installation

### Prerequisites

- Java Runtime Environment (JRE) 8 or higher
- For Bash version: Standard Unix tools (bash, wget, unzip)
- For Lisp version: SBCL (Steel Bank Common Lisp)

### Step 1: Extract the Archive

```bash
unzip jar-decompiler-tool.zip
cd jar-decompiler-tool
```

### Step 2: Install Decompiler Tools

```bash
cd bash
./install-decompilers.sh
```

This will download:
- CFR (Class File Reader)
- Fernflower
- Procyon

## Usage

### Basic Usage

```bash
# Using Bash version
bash/jar-decompiler.sh <jar_file>

# Using Lisp version
lisp/jar-decompiler-lisp <jar_file>
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `-o <dir>` | Output directory | `<jar_name>_src` |
| `-d <type>` | Decompiler: cfr, fernflower, procyon | `cfr` |
| `-v` | Verbose output | Off |
| `-k` | Keep .class files after decompilation | Off |
| `-h` | Show help message | - |

### Examples

```bash
# Decompile with specific output directory
bash/jar-decompiler.sh -o output_dir myapp.jar

# Use Procyon decompiler with verbose mode
bash/jar-decompiler.sh -d procyon -v myapp.jar

# Keep class files for inspection
bash/jar-decompiler.sh -k library.jar

# Lisp version with Fernflower
lisp/jar-decompiler-lisp -d fernflower myapp.jar
```

## Decompiler Comparison

| Decompiler | Speed | Accuracy | Modern Java Support | Best For |
|------------|-------|----------|-------------------|----------|
| **CFR** | Fast | High | Excellent | Default choice, Java 8+ features |
| **Fernflower** | Medium | High | Good | IntelliJ IDEA compatibility |
| **Procyon** | Slow | Very High | Excellent | Complex code structures |

## Directory Structure

```
jar-decompiler-tool/
├── bash/                   # Linux/macOS implementation
│   ├── jar-decompiler.sh
│   └── install-decompilers.sh
├── windows/                # Windows implementation
│   ├── jar-decompiler.bat      # Batch script
│   ├── jar-decompiler.ps1      # PowerShell script
│   ├── install-decompilers.bat # Windows installer
│   └── README_WINDOWS.md       # Windows documentation
├── lisp/                   # Common Lisp implementation
│   ├── jar-decompiler.lisp
│   └── jar-decompiler-lisp
├── docs/                   # Documentation
│   ├── README_JAR_DECOMPILER.md
│   └── README_LISP_DECOMPILER.md
├── examples/               # Example files
│   └── test/
│       ├── HelloWorld.java
│       └── sample.jar
├── LICENSE                # MIT License
└── README.md              # This file
```

## Platform Support

| Platform | Batch | PowerShell | Bash | Lisp |
|----------|-------|------------|------|------|
| **Windows** | ✅ Native | ✅ Native | ⚠️ WSL/Git Bash | ⚠️ Requires SBCL |
| **Linux** | ❌ | ✅ pwsh | ✅ Native | ✅ Requires SBCL |
| **macOS** | ❌ | ✅ pwsh | ✅ Native | ✅ Requires SBCL |

## Implementation Comparison

| Aspect | Windows Batch | PowerShell | Bash | Lisp |
|--------|---------------|------------|------|------|
| **Performance** | Good | Good | Best | Good |
| **Dependencies** | None | PS 5.1+ | Unix tools | SBCL |
| **Ease of use** | Very Easy | Easy | Easy | Advanced |
| **Cross-platform** | No | Yes | Unix only | Yes |

## Testing

Test with the included sample JAR:

```bash
# Test Bash version
bash/jar-decompiler.sh examples/test/sample.jar

# Test Lisp version
lisp/jar-decompiler-lisp examples/test/sample.jar

# Verify output
ls sample_src/com/example/test/
```

## Troubleshooting

### Java Not Found

```bash
# Ubuntu/Debian
sudo apt-get install default-jdk

# RHEL/CentOS
sudo yum install java-11-openjdk

# macOS
brew install openjdk
```

### SBCL Not Found (Lisp version only)

```bash
# Ubuntu/Debian
sudo apt-get install sbcl

# macOS
brew install sbcl

# From source
wget http://prdownloads.sourceforge.net/sbcl/sbcl-2.3.0-x86-64-linux-binary.tar.bz2
tar xjf sbcl-*.tar.bz2
cd sbcl-*
sudo sh install.sh
```

### Decompilation Fails

Try different decompilers:
```bash
# Try Fernflower if CFR fails
bash/jar-decompiler.sh -d fernflower problematic.jar

# Try Procyon for complex code
bash/jar-decompiler.sh -d procyon complex.jar
```

### Memory Issues

For large JAR files, increase Java heap size by editing the script and adding `-Xmx2G` to java commands.

## Performance

Test results with a 3-class sample JAR:

| Implementation | Real Time | User Time | Sys Time |
|----------------|-----------|-----------|----------|
| Bash | 1.241s | 2.593s | 0.420s |
| Lisp | 1.333s | 2.623s | 0.433s |

## Use Cases

### When to Use Bash Version
- Quick one-time decompilation
- CI/CD pipelines
- Minimal dependencies required
- Team environments

### When to Use Lisp Version
- Need for customization
- Complex decompilation workflows
- Interactive development
- Advanced error recovery

## Legal Notice

This tool is for educational and debugging purposes. Please respect software licenses and copyrights when decompiling JAR files. Only decompile software you have the legal right to examine.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See LICENSE file for details

## Author

Created with Claude Code Assistant

## Acknowledgments

- [CFR](https://github.com/leibnitz27/cfr) by Lee Benfield
- [Fernflower](https://github.com/fesh0r/fernflower) by JetBrains
- [Procyon](https://github.com/mstrobel/procyon) by Mike Strobel

## Support

For issues or questions, please open an issue on GitHub.