#!/bin/bash
# ==============================================================
# Test Harness for Assignment 2 - Java 1.2 Parser (ANTLR & JavaCC)
# ==============================================================
# This script builds both parsers and runs them against test files.
# Usage: ./run_tests.sh
# ==============================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANTLR_DIR="$SCRIPT_DIR/ANTLR"
JAVACC_DIR="$SCRIPT_DIR/JavaCC"
TESTS_DIR="$SCRIPT_DIR/TESTS"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "============================================================"
echo "  Assignment 2 - Test Harness"
echo "  Java 1.2 Parser: ANTLR and JavaCC"
echo "============================================================"
echo ""

# --------------------------------------------------
# Check prerequisites
# --------------------------------------------------
echo -e "${BLUE}[INFO]${NC} Checking prerequisites..."

ANTLR_JAR=""
if [ -f "$SCRIPT_DIR/lib/antlr-4.13.2-complete.jar" ]; then
    ANTLR_JAR="$SCRIPT_DIR/lib/antlr-4.13.2-complete.jar"
elif [ -n "$ANTLR_JAR_PATH" ]; then
    ANTLR_JAR="$ANTLR_JAR_PATH"
else
    echo -e "${YELLOW}[WARN]${NC} ANTLR jar not found. Downloading..."
    mkdir -p "$SCRIPT_DIR/lib"
    curl -sSL -o "$SCRIPT_DIR/lib/antlr-4.13.2-complete.jar" \
        "https://www.antlr.org/download/antlr-4.13.2-complete.jar" 2>/dev/null || true
    if [ -f "$SCRIPT_DIR/lib/antlr-4.13.2-complete.jar" ]; then
        ANTLR_JAR="$SCRIPT_DIR/lib/antlr-4.13.2-complete.jar"
    fi
fi

JAVACC_JAR=""
if [ -f "$SCRIPT_DIR/lib/javacc.jar" ]; then
    JAVACC_JAR="$SCRIPT_DIR/lib/javacc.jar"
elif command -v javacc &>/dev/null; then
    JAVACC_JAR="javacc"
fi

# --------------------------------------------------
# STEP 1: Build ANTLR parser
# --------------------------------------------------
echo ""
echo -e "${BLUE}[STEP 1]${NC} Building ANTLR parser..."

if [ -n "$ANTLR_JAR" ] && [ -f "$ANTLR_JAR" ]; then
    cd "$ANTLR_DIR"
    echo "  Generating parser from grammars..."
    java -jar "$ANTLR_JAR" Java1_2ANTLRLexer.g4 Java1_2ANTLRParser.g4 2>&1 | head -20

    echo "  Compiling generated code + analysis tool..."
    javac -cp "$ANTLR_JAR:." *.java 2>&1 | head -20

    ANTLR_READY=true
    echo -e "  ${GREEN}ANTLR parser built successfully.${NC}"
else
    ANTLR_READY=false
    echo -e "  ${YELLOW}Skipping ANTLR build (jar not available).${NC}"
fi

# --------------------------------------------------
# STEP 2: Build JavaCC parser
# --------------------------------------------------
echo ""
echo -e "${BLUE}[STEP 2]${NC} Building JavaCC parser..."

cd "$JAVACC_DIR"
mkdir -p generated/javacc

if command -v javacc &>/dev/null; then
    echo "  Generating parser from grammar..."
    javacc -OUTPUT_DIRECTORY=generated/javacc Java1_2JavaCCParserAnalysis.jj 2>&1 | tail -5

    echo "  Compiling generated code + analysis tool..."
    cp JavaccInvocationFinder.java generated/javacc/
    cd generated
    javac javacc/*.java 2>&1 | head -20

    JAVACC_READY=true
    echo -e "  ${GREEN}JavaCC parser built successfully.${NC}"
    cd "$JAVACC_DIR"
elif [ -n "$JAVACC_JAR" ] && [ -f "$JAVACC_JAR" ]; then
    echo "  Generating parser from grammar..."
    java -cp "$JAVACC_JAR" javacc -OUTPUT_DIRECTORY=generated/javacc Java1_2JavaCCParserAnalysis.jj 2>&1 | tail -5

    echo "  Compiling generated code + analysis tool..."
    cp JavaccInvocationFinder.java generated/javacc/
    cd generated
    javac javacc/*.java 2>&1 | head -20

    JAVACC_READY=true
    echo -e "  ${GREEN}JavaCC parser built successfully.${NC}"
    cd "$JAVACC_DIR"
else
    JAVACC_READY=false
    echo -e "  ${YELLOW}Skipping JavaCC build (javacc not available).${NC}"
fi

# --------------------------------------------------
# STEP 3: Run tests
# --------------------------------------------------
echo ""
echo "============================================================"
echo "  Running Tests"
echo "============================================================"

VALID_FILES=("Test1_Valid.java" "Test2_Valid.java" "Test3_Minimal.java" "Test4_Empty.java" "Test9_Valid_EdgeCases.java")
INVALID_FILES=("Test5_Invalid_MissingSemicolon.java" "Test6_Invalid_BadSyntax.java" "Test7_Invalid_Java5Features.java" "Test8_Invalid_NotJava.txt")

pass_count=0
fail_count=0
skip_count=0

run_antlr_parse_test() {
    local file="$1"
    local expect_success="$2"
    local filepath="$TESTS_DIR/$file"

    if [ "$ANTLR_READY" != "true" ]; then
        echo -e "    ${YELLOW}[SKIP]${NC} ANTLR: $file"
        ((skip_count++))
        return
    fi

    cd "$ANTLR_DIR"
    output=$(java -cp "$ANTLR_JAR:." org.antlr.v4.gui.TestRig Java1_2ANTLRParser compilationUnit "$filepath" 2>&1)
    exit_code=$?

    # Check for errors in output
    has_errors=false
    if echo "$output" | grep -qi "error\|exception\|mismatched\|no viable\|extraneous"; then
        has_errors=true
    fi

    if [ "$expect_success" = "true" ]; then
        if [ "$has_errors" = "false" ]; then
            echo -e "    ${GREEN}[PASS]${NC} ANTLR accepts: $file"
            ((pass_count++))
        else
            echo -e "    ${RED}[FAIL]${NC} ANTLR should accept: $file"
            echo "           Output: $(echo "$output" | head -3)"
            ((fail_count++))
        fi
    else
        if [ "$has_errors" = "true" ]; then
            echo -e "    ${GREEN}[PASS]${NC} ANTLR rejects: $file"
            ((pass_count++))
        else
            echo -e "    ${RED}[FAIL]${NC} ANTLR should reject: $file"
            ((fail_count++))
        fi
    fi
}

run_javacc_parse_test() {
    local file="$1"
    local expect_success="$2"
    local filepath="$TESTS_DIR/$file"

    if [ "$JAVACC_READY" != "true" ]; then
        echo -e "    ${YELLOW}[SKIP]${NC} JavaCC: $file"
        ((skip_count++))
        return
    fi

    cd "$JAVACC_DIR/generated"
    output=$(java javacc.Java1_2JavaCCParserAnalysis < "$filepath" 2>&1)
    exit_code=$?

    has_errors=false
    if echo "$output" | grep -qi "error\|exception\|ParseException\|TokenMgrError"; then
        has_errors=true
    fi
    if [ $exit_code -ne 0 ]; then
        has_errors=true
    fi

    if [ "$expect_success" = "true" ]; then
        if [ "$has_errors" = "false" ]; then
            echo -e "    ${GREEN}[PASS]${NC} JavaCC accepts: $file"
            ((pass_count++))
        else
            echo -e "    ${RED}[FAIL]${NC} JavaCC should accept: $file"
            echo "           Output: $(echo "$output" | head -3)"
            ((fail_count++))
        fi
    else
        if [ "$has_errors" = "true" ]; then
            echo -e "    ${GREEN}[PASS]${NC} JavaCC rejects: $file"
            ((pass_count++))
        else
            echo -e "    ${RED}[FAIL]${NC} JavaCC should reject: $file"
            ((fail_count++))
        fi
    fi
}

# --- Valid files should be accepted ---
echo ""
echo -e "${BLUE}--- Testing valid Java 1.2 files (should be accepted) ---${NC}"
for f in "${VALID_FILES[@]}"; do
    run_antlr_parse_test "$f" "true"
    run_javacc_parse_test "$f" "true"
done

# --- Invalid files should be rejected ---
echo ""
echo -e "${BLUE}--- Testing invalid files (should be rejected) ---${NC}"
for f in "${INVALID_FILES[@]}"; do
    run_antlr_parse_test "$f" "false"
    run_javacc_parse_test "$f" "false"
done

# --------------------------------------------------
# STEP 4: Run invocation finder tools
# --------------------------------------------------
echo ""
echo "============================================================"
echo "  Running Invocation Finder Analysis"
echo "============================================================"

if [ "$ANTLR_READY" = "true" ]; then
    echo ""
    echo -e "${BLUE}--- ANTLR Invocation Finder ---${NC}"
    cd "$ANTLR_DIR"
    for f in "${VALID_FILES[@]}"; do
        echo ""
        echo "  File: $f"
        java -cp "$ANTLR_JAR:." AntlrInvocationFinder "$TESTS_DIR/$f" 2>&1 | head -30
    done
fi

if [ "$JAVACC_READY" = "true" ]; then
    echo ""
    echo -e "${BLUE}--- JavaCC Invocation Finder ---${NC}"
    cd "$JAVACC_DIR/generated"
    for f in "${VALID_FILES[@]}"; do
        echo ""
        echo "  File: $f"
        java javacc.JavaccInvocationFinder "$TESTS_DIR/$f" 2>&1 | head -30
    done
fi

# --------------------------------------------------
# Summary
# --------------------------------------------------
echo ""
echo "============================================================"
echo "  Test Summary"
echo "============================================================"
echo -e "  ${GREEN}Passed:${NC}  $pass_count"
echo -e "  ${RED}Failed:${NC}  $fail_count"
echo -e "  ${YELLOW}Skipped:${NC} $skip_count"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "  ${GREEN}All executed tests passed!${NC}"
else
    echo -e "  ${RED}Some tests failed. Review output above.${NC}"
fi
echo ""
