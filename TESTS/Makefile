# ==============================================================
# Makefile for Assignment 2 - Java 1.2 Parser (ANTLR & JavaCC)
# ==============================================================
#
# Targets:
#   make all       - Build both ANTLR and JavaCC parsers
#   make antlr     - Build ANTLR parser only
#   make javacc    - Build JavaCC parser only
#   make test      - Run the test harness
#   make clean     - Remove all generated files
#
# Prerequisites:
#   - Java JDK 8+ (javac, java)
#   - ANTLR 4.x jar (set ANTLR_JAR or place in lib/)
#   - JavaCC (javacc command on PATH or set JAVACC_JAR)
# ==============================================================

ANTLR_JAR ?= lib/antlr-4.13.2-complete.jar
JAVACC_CMD ?= javacc

ANTLR_DIR = antlr
JAVACC_DIR = javacc
TESTS_DIR = tests

.PHONY: all antlr javacc test clean

all: antlr javacc

# --- ANTLR ---
antlr: $(ANTLR_JAR)
	@echo "=== Building ANTLR parser ==="
	cd $(ANTLR_DIR) && \
	java -jar ../$(ANTLR_JAR) -visitor Java12Lexer.g4 Java12Parser.g4 && \
	javac -cp ../$(ANTLR_JAR):. *.java
	@echo "=== ANTLR build complete ==="

# --- JavaCC ---
javacc:
	@echo "=== Building JavaCC parser ==="
	mkdir -p $(JAVACC_DIR)/generated/javacc
	cd $(JAVACC_DIR) && \
	$(JAVACC_CMD) -OUTPUT_DIRECTORY=generated/javacc Java12Parser.jj && \
	$(JAVACC_CMD) -OUTPUT_DIRECTORY=generated/javacc Java12ParserAnalysis.jj && \
	cp JavaccInvocationFinder.java generated/javacc/ && \
	cd generated && javac javacc/*.java
	@echo "=== JavaCC build complete ==="

# --- Test ---
test: all
	@echo "=== Running tests ==="
	./run_tests.sh

# --- Clean ---
clean:
	@echo "=== Cleaning generated files ==="
	cd $(ANTLR_DIR) && rm -f *.class *.tokens *.interp Java12Lexer.java Java12Parser.java \
		Java12ParserBaseListener.java Java12ParserListener.java \
		Java12ParserBaseVisitor.java Java12ParserVisitor.java
	rm -rf $(JAVACC_DIR)/generated
	@echo "=== Clean complete ==="
