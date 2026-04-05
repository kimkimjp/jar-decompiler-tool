#!/bin/bash

# Installation script for Java decompiler tools
# Downloads CFR, Fernflower, and Procyon decompilers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Installation directory
INSTALL_DIR="$HOME/decompiler-tools"

print_info "Java Decompiler Tools Installer"
print_info "================================"
echo ""

# Create installation directory
print_info "Creating installation directory: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Check if Java is installed
print_info "Checking Java installation..."
if ! command -v java &> /dev/null; then
    print_error "Java is not installed. Please install Java first."
    echo "  On Ubuntu/Debian: sudo apt-get install default-jdk"
    echo "  On RHEL/CentOS: sudo yum install java-11-openjdk"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1)
print_success "Java found: $JAVA_VERSION"
echo ""

# Download CFR
print_info "Downloading CFR (Class File Reader)..."
if [ -f "$INSTALL_DIR/cfr.jar" ]; then
    print_warning "CFR already exists, skipping..."
else
    wget --progress=bar:force:noscroll "https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar" -O "$INSTALL_DIR/cfr.jar" 2>&1 | grep -E "%" || {
        print_error "Failed to download CFR"
        exit 1
    }
    print_success "CFR downloaded successfully"
fi

# Download Fernflower
print_info "Downloading Fernflower..."
if [ -f "$INSTALL_DIR/fernflower.jar" ]; then
    print_warning "Fernflower already exists, skipping..."
else
    wget --progress=bar:force:noscroll "https://github.com/fesh0r/fernflower/releases/download/v1.1.1/fernflower-1.1.1.jar" -O "$INSTALL_DIR/fernflower.jar" 2>&1 | grep -E "%" || {
        print_error "Failed to download Fernflower"
        exit 1
    }
    print_success "Fernflower downloaded successfully"
fi

# Download Procyon
print_info "Downloading Procyon..."
if [ -f "$INSTALL_DIR/procyon.jar" ]; then
    print_warning "Procyon already exists, skipping..."
else
    wget --progress=bar:force:noscroll "https://github.com/mstrobel/procyon/releases/download/v0.6.0/procyon-decompiler-0.6.0.jar" -O "$INSTALL_DIR/procyon.jar" 2>&1 | grep -E "%" || {
        print_error "Failed to download Procyon"
        exit 1
    }
    print_success "Procyon downloaded successfully"
fi

echo ""
print_success "=== Installation Complete ==="
echo ""
print_info "Decompiler tools installed in: $INSTALL_DIR"
echo ""
print_info "Installed tools:"
echo "  - CFR (cfr.jar)"
echo "  - Fernflower (fernflower.jar)"
echo "  - Procyon (procyon.jar)"
echo ""
print_info "You can now use the jar-decompiler.sh script to decompile JAR files"
print_info "Example: ./jar-decompiler.sh myapp.jar"