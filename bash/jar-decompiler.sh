#!/bin/bash

# JAR Decompiler Tool
# Extracts and decompiles JAR files to Java source code

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DECOMPILER="cfr"
OUTPUT_DIR=""
KEEP_CLASS_FILES=false
VERBOSE=false

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

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] <jar_file>

JAR Decompiler Tool - Extracts and decompiles JAR files to Java source code

OPTIONS:
    -o, --output <dir>      Output directory (default: <jar_name>_src)
    -d, --decompiler <type> Decompiler to use: cfr, fernflower, procyon (default: cfr)
    -k, --keep-class        Keep .class files after decompilation
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

EXAMPLES:
    $0 myapp.jar
    $0 -o output_dir -d fernflower myapp.jar
    $0 --keep-class --verbose library.jar

SUPPORTED DECOMPILERS:
    cfr         - CFR (Class File Reader) - Fast and reliable
    fernflower  - Fernflower - IntelliJ IDEA's decompiler
    procyon     - Procyon - Handles modern Java features well

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -d|--decompiler)
            DECOMPILER="$2"
            shift 2
            ;;
        -k|--keep-class)
            KEEP_CLASS_FILES=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            JAR_FILE="$1"
            shift
            ;;
    esac
done

# Check if JAR file is provided
if [ -z "$JAR_FILE" ]; then
    print_error "No JAR file specified"
    show_usage
    exit 1
fi

# Check if JAR file exists
if [ ! -f "$JAR_FILE" ]; then
    print_error "JAR file not found: $JAR_FILE"
    exit 1
fi

# Set output directory if not specified
if [ -z "$OUTPUT_DIR" ]; then
    JAR_NAME=$(basename "$JAR_FILE" .jar)
    OUTPUT_DIR="${JAR_NAME}_src"
fi

# Create output directory
print_info "Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Get absolute paths
JAR_FILE=$(realpath "$JAR_FILE")
OUTPUT_DIR=$(realpath "$OUTPUT_DIR")

# Extract JAR file
print_info "Extracting JAR file..."
cd "$OUTPUT_DIR"
jar xf "$JAR_FILE" 2>/dev/null || unzip -q "$JAR_FILE" 2>/dev/null || {
    print_error "Failed to extract JAR file"
    exit 1
}
print_success "JAR file extracted"

# Find all .class files
print_info "Finding .class files..."
CLASS_FILES=$(find . -name "*.class" -type f)
CLASS_COUNT=$(echo "$CLASS_FILES" | grep -c "\.class" || echo 0)
print_info "Found $CLASS_COUNT class files"

# Decompile based on selected decompiler
case $DECOMPILER in
    cfr)
        # Check if CFR is available
        CFR_JAR="$HOME/decompiler-tools/cfr.jar"
        if [ ! -f "$CFR_JAR" ]; then
            print_warning "CFR not found. Downloading..."
            mkdir -p "$HOME/decompiler-tools"
            wget -q "https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar" -O "$CFR_JAR" || {
                print_error "Failed to download CFR"
                exit 1
            }
            print_success "CFR downloaded"
        fi

        print_info "Decompiling with CFR..."
        # Process each class file
        while IFS= read -r -d '' CLASS_FILE; do
            if [ "$VERBOSE" = true ]; then
                echo "  Decompiling: $CLASS_FILE"
            fi
            # Get the directory and filename
            DIR=$(dirname "$CLASS_FILE")
            BASENAME=$(basename "$CLASS_FILE" .class)

            # Decompile to .java file
            java -jar "$CFR_JAR" "$CLASS_FILE" > "${DIR}/${BASENAME}.java" 2>/dev/null || {
                print_warning "Failed to decompile: $CLASS_FILE"
            }
        done < <(find "$OUTPUT_DIR" -name "*.class" -type f -print0)
        ;;

    fernflower)
        # Check if Fernflower is available
        FERNFLOWER_JAR="$HOME/decompiler-tools/fernflower.jar"
        if [ ! -f "$FERNFLOWER_JAR" ]; then
            print_warning "Fernflower not found. Downloading..."
            mkdir -p "$HOME/decompiler-tools"
            wget -q "https://github.com/fesh0r/fernflower/releases/download/v1.1.1/fernflower-1.1.1.jar" -O "$FERNFLOWER_JAR" || {
                print_error "Failed to download Fernflower"
                exit 1
            }
            print_success "Fernflower downloaded"
        fi

        print_info "Decompiling with Fernflower..."
        java -jar "$FERNFLOWER_JAR" -dgs=1 "$JAR_FILE" "$OUTPUT_DIR/decompiled" 2>/dev/null || {
            print_error "Fernflower decompilation failed"
            exit 1
        }

        # Extract the decompiled JAR
        if [ -f "$OUTPUT_DIR/decompiled/$(basename "$JAR_FILE")" ]; then
            cd "$OUTPUT_DIR/decompiled"
            jar xf "$(basename "$JAR_FILE")" 2>/dev/null || unzip -q "$(basename "$JAR_FILE")" 2>/dev/null
            rm "$(basename "$JAR_FILE")"
            # Move decompiled files to main output directory
            cp -r ./* ../ 2>/dev/null
            cd ..
            rm -rf decompiled
        fi
        ;;

    procyon)
        # Check if Procyon is available
        PROCYON_JAR="$HOME/decompiler-tools/procyon.jar"
        if [ ! -f "$PROCYON_JAR" ]; then
            print_warning "Procyon not found. Downloading..."
            mkdir -p "$HOME/decompiler-tools"
            wget -q "https://github.com/mstrobel/procyon/releases/download/v0.6.0/procyon-decompiler-0.6.0.jar" -O "$PROCYON_JAR" || {
                print_error "Failed to download Procyon"
                exit 1
            }
            print_success "Procyon downloaded"
        fi

        print_info "Decompiling with Procyon..."
        # Process each class file
        while IFS= read -r -d '' CLASS_FILE; do
            if [ "$VERBOSE" = true ]; then
                echo "  Decompiling: $CLASS_FILE"
            fi
            # Get the directory and filename
            DIR=$(dirname "$CLASS_FILE")
            BASENAME=$(basename "$CLASS_FILE" .class)

            # Decompile to .java file
            java -jar "$PROCYON_JAR" "$CLASS_FILE" > "${DIR}/${BASENAME}.java" 2>/dev/null || {
                print_warning "Failed to decompile: $CLASS_FILE"
            }
        done < <(find "$OUTPUT_DIR" -name "*.class" -type f -print0)
        ;;

    *)
        print_error "Unknown decompiler: $DECOMPILER"
        exit 1
        ;;
esac

print_success "Decompilation completed"

# Remove .class files if requested
if [ "$KEEP_CLASS_FILES" = false ]; then
    print_info "Removing .class files..."
    find "$OUTPUT_DIR" -name "*.class" -type f -delete
    print_success ".class files removed"
fi

# Count decompiled files
JAVA_COUNT=$(find "$OUTPUT_DIR" -name "*.java" -type f | wc -l)

# Summary
echo ""
print_success "=== Decompilation Summary ==="
echo "  JAR file:        $JAR_FILE"
echo "  Output directory: $OUTPUT_DIR"
echo "  Decompiler used: $DECOMPILER"
echo "  Java files created: $JAVA_COUNT"
echo ""
print_info "You can now browse the decompiled source code in: $OUTPUT_DIR"