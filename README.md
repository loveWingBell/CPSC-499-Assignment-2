# Assignment 2 - Java 1.2 Parser (ANTLR & JavaCC)

## Project Structure

```
assignment2/
├── antlr/
│   ├── Java1_2ANTLRLexer.g4                 # ANTLR lexer grammar
│   ├── Java1_2ANTLERParser.g4               # ANTLR parser grammar
│   └── AntlrInvocationFinder.java           # ANTLR-based invocation analysis tool
├── javacc/
│   ├── Java1_2JavaCCParser.jj               # JavaCC grammar (plain parser)
│   ├── Java1_2JavaCCAnalysis.jj             # JavaCC grammar with invocation tracking
│   └── JavaccInvocationFinder.java          # JavaCC-based invocation analysis driver
├── tests/
│   ├── Test1_Valid.java                     # Valid: constructors, method calls, chaining
│   ├── Test2_Valid.java                     # Valid: interfaces, inheritance, inner classes
│   ├── Test3_Minimal.java                   # Valid: minimal Hello World
│   ├── Test4_Empty.java                     # Valid: empty compilation unit
│   ├── Test5_Invalid_MissingSemicolon.java  # Invalid: missing semicolons
│   ├── Test6_Invalid_BadSyntax.java         # Invalid: various syntax errors
│   ├── Test7_Invalid_Java5Features.java     # Invalid: generics, enhanced for
│   ├── Test8_Invalid_NotJava.txt            # Invalid: not Java at all
│   └── Test9_Valid_EdgeCases.java           # Valid: strictfp, labels, complex exprs
│
├── CPSC 499.02 A2-4 Report.pdf              # Report
├── Makefile                                 # Makefile
└── README.md                                # Guide to this repository
├── run_tests.sh                             # Test harness
```

## Prerequisites

- Java JDK 8+
- ANTLR 4.x (jar will be auto-downloaded by test harness)
- JavaCC 7.x (`javacc` command on PATH)

## Building

```bash
# Build everything
make all

# Build individually
make antlr
make javacc
```

## Running Tests

```bash
./run_tests.sh
# or
make test
```

## Running the Analysis Tools

```bash
# ANTLR
cd antlr
java -cp "path/to/antlr.jar:." AntlrInvocationFinder ../tests/Test1_Valid.java

# JavaCC
cd javacc/generated
java javacc.JavaccInvocationFinder ../../tests/Test1_Valid.java
```
