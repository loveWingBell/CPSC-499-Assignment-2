/* CPSC 499.02 - Assignment 2 - Group 4
- Elda Britu - 30158734
- Collin Mtendamema - 30139450
- MD Saif Al-Deen - 30197566
- Rylan Laplante - 30070936
*/

parser grammar Java1_2ANTLRParser;

options {
    tokenVocab = Java1_2ANTLRLexer;
}

/* CompilationUnit:
    [package QualifiedIdentifier ; ] {ImportDeclaration} {TypeDeclaration}
*/
compilationUnit
    : (PACKAGE qualifiedIdentifier SEMICOLON)?
      importDeclaration*
      typeDeclaration*
      EOF
    ;

// Identifier { . Identifier }
qualifiedIdentifier
    : Identifier (PERIOD Identifier)*
    ;

/* ImportDeclaration:
    import Identifier { .Identifier } [ .* ] ;
*/
importDeclaration
    : IMPORT Identifier (PERIOD Identifier)* (PERIOD ASTERISK)? SEMICOLON
    ;

/* TypeDeclaration:
    ClassOrInterfaceDeclaration
    ;
 */
typeDeclaration
    : classOrInterfaceDeclaration
    | SEMICOLON
    ;

/* ClassOrInterfaceDeclaration:
    ModifiersOpt (ClassDeclaration | InterfaceDeclaration)
*/
classOrInterfaceDeclaration
    : modifier* (classDeclaration | interfaceDeclaration)
    ;

// ModifiersOpt: { Modifier }
modifier
    : PUBLIC | PROTECTED | PRIVATE | STATIC | ABSTRACT
    | FINAL | NATIVE | SYNCHRONIZED | TRANSIENT | VOLATILE | STRICTFP
    ;

/* ClassDeclaration:
    class Identifier [extends Type] [implements TypeList] ClassBody
*/
classDeclaration
    : CLASS Identifier (EXTENDS type)? (IMPLEMENTS typeList)? classBody
    ;

// Interface Declaration
interfaceDeclaration
    : INTERFACE Identifier (EXTENDS typeList)? interfaceBody
    ;

/* Type:
    Identifier { .Identifier } BracketsOpt
    BasicType
*/
type
    : Identifier (PERIOD Identifier)* bracketsOpt
    | basicType bracketsOpt
    ;

typeList
    : type (COMMA type)*
    ;

basicType
    : BYTE | SHORT | CHAR | INT | LONG | FLOAT | DOUBLE | BOOLEAN
    ;

bracketsOpt
    : (OPEN_BRACKET CLOSE_BRACKET)*
    ;

// Class body
classBody
    : OPEN_BRACE classBodyDeclaration* CLOSE_BRACE
    ;

classBodyDeclaration
    : SEMICOLON
    | STATIC? block
    | modifier* memberDecl
    ;

memberDecl
    : methodOrFieldDecl
    | VOID Identifier voidMethodDeclaratorRest
    | Identifier constructorDeclaratorRest
    | classOrInterfaceDeclaration
    ;

methodOrFieldDecl
    : type Identifier methodOrFieldRest
    ;

methodOrFieldRest
    : fieldDeclaratorsRest SEMICOLON
    | methodDeclaratorRest
    ;

// Handles the rest of the first declarator plus any additional comma-separated ones.
fieldDeclaratorsRest
    : variableDeclaratorRest (COMMA variableDeclarator)*
    ;

// Interface Body
interfaceBody
    : OPEN_BRACE interfaceBodyDeclaration* CLOSE_BRACE
    ;

interfaceBodyDeclaration
    : SEMICOLON
    | modifier* interfaceMemberDecl
    ;

interfaceMemberDecl
    : interfaceMethodOrFieldDecl
    | VOID Identifier voidInterfaceMethodDeclaratorRest
    | classOrInterfaceDeclaration
    ;

interfaceMethodOrFieldDecl
    : type Identifier interfaceMethodOrFieldRest
    ;

interfaceMethodOrFieldRest
    : constantDeclaratorsRest SEMICOLON
    | interfaceMethodDeclaratorRest
    ;

// Method and constructor declarations
methodDeclaratorRest
    : formalParameters bracketsOpt (THROWS qualifiedIdentifierList)? (methodBody | SEMICOLON)
    ;

voidMethodDeclaratorRest
    : formalParameters (THROWS qualifiedIdentifierList)? (methodBody | SEMICOLON)
    ;

interfaceMethodDeclaratorRest
    : formalParameters bracketsOpt (THROWS qualifiedIdentifierList)? SEMICOLON
    ;

voidInterfaceMethodDeclaratorRest
    : formalParameters (THROWS qualifiedIdentifierList)? SEMICOLON
    ;

constructorDeclaratorRest
    : formalParameters (THROWS qualifiedIdentifierList)? methodBody
    ;

methodBody
    : block
    ;

formalParameters
    : OPEN_PARENTHESIS (formalParameter (COMMA formalParameter)*)? CLOSE_PARENTHESIS
    ;

formalParameter
    : FINAL? type variableDeclaratorId
    ;

qualifiedIdentifierList
    : qualifiedIdentifier (COMMA qualifiedIdentifier)*
    ;

// Variable declarations
variableDeclarators
    : variableDeclarator (COMMA variableDeclarator)*
    ;

variableDeclarator
    : Identifier variableDeclaratorRest
    ;

variableDeclaratorRest
    : bracketsOpt (EQUALS variableInitializer)?
    ;

constantDeclarator
    : Identifier constantDeclaratorRest
    ;

constantDeclaratorRest
    : bracketsOpt EQUALS variableInitializer
    ;

constantDeclaratorsRest
    : constantDeclaratorRest (COMMA constantDeclarator)*
    ;

variableDeclaratorId
    : Identifier bracketsOpt
    ;

variableInitializer
    : arrayInitializer
    | expression
    ;

arrayInitializer
    : OPEN_BRACE (variableInitializer (COMMA variableInitializer)* (COMMA)?)? CLOSE_BRACE
    ;

// Blocks and statements
block
    : OPEN_BRACE blockStatement* CLOSE_BRACE
    ;

blockStatement
    : localVariableDeclarationStatement
    | classOrInterfaceDeclaration
    | statement
    ;

localVariableDeclarationStatement
    : FINAL? type variableDeclarators SEMICOLON
    ;

statement
    : block
    | IF parExpression statement (ELSE statement)?
    | FOR OPEN_PARENTHESIS forInit? SEMICOLON expression? SEMICOLON forUpdate? CLOSE_PARENTHESIS statement
    | WHILE parExpression statement
    | DO statement WHILE parExpression SEMICOLON
    | TRY block (catches | catches? FINALLY block)
    | SWITCH parExpression OPEN_BRACE switchBlockStatementGroup* CLOSE_BRACE
    | SYNCHRONIZED parExpression block
    | RETURN expression? SEMICOLON
    | THROW expression SEMICOLON
    | BREAK Identifier? SEMICOLON
    | CONTINUE Identifier? SEMICOLON
    | SEMICOLON
    | statementExpression SEMICOLON
    | Identifier COLON statement
    ;

catches
    : catchClause+
    ;

catchClause
    : CATCH OPEN_PARENTHESIS formalParameter CLOSE_PARENTHESIS block
    ;

switchBlockStatementGroup
    : switchLabel blockStatement*
    ;

switchLabel
    : CASE constantExpression COLON
    | DEFAULT COLON
    ;

forInit
    : statementExpression (COMMA statementExpression)*
    | FINAL? type variableDeclarators
    ;

forUpdate
    : statementExpression (COMMA statementExpression)*
    ;

parExpression
    : OPEN_PARENTHESIS expression CLOSE_PARENTHESIS
    ;

// Expressions
statementExpression
    : expression
    ;

constantExpression
    : expression
    ;

// Main expression rule - handles assignment
expression
    : expression1 (assignmentOperator expression)?
    ;

assignmentOperator
    : EQUALS | PLUS_EQUALS | MINUS_EQUALS | ASTERISK_EQUALS | SLASH_EQUALS
    | AMPERSAND_EQUALS | PIPE_EQUALS | CARET_EQUALS | PERCENT_EQUALS
    | DOUBLE_LESS_THAN_EQUALS | DOUBLE_GREATER_THAN_EQUALS | TRIPLE_GREATER_THAN_EQUALS
    ;

// Ternary conditional
expression1
    : expression2 (QUESTION expression COLON expression1)?
    ;

// Infix operators
expression2
    : expression3 (infixOp expression3 | INSTANCEOF type)*
    ;

infixOp
    : DOUBLE_PIPE | DOUBLE_AMPERSAND | PIPE | CARET | AMPERSAND
    | DOUBLE_EQUALS | EXCLAMATION_EQUALS
    | LESS_THAN | GREATER_THAN | LESS_THAN_OR_EQUALS | GREATER_THAN_OR_EQUALS
    | DOUBLE_LESS_THAN | DOUBLE_GREATER_THAN | TRIPLE_GREATER_THAN
    | PLUS | MINUS | ASTERISK | SLASH | PERCENT
    ;

// Prefix, cast, and postfix
expression3
    : prefixOp expression3
    | OPEN_PARENTHESIS basicType bracketsOpt CLOSE_PARENTHESIS expression3  // primitive cast
    | OPEN_PARENTHESIS expression CLOSE_PARENTHESIS expression3             // reference cast or grouped expr
    | primary selector* postfixOp*
    ;

prefixOp
    : DOUBLE_PLUS | DOUBLE_MINUS | EXCLAMATION | TILDE | PLUS | MINUS
    ;

postfixOp
    : DOUBLE_PLUS | DOUBLE_MINUS
    ;

/* Primary expressions
Primary:
    (Expression)
    this [Arguments]
    super SuperSuffix
    Literal
    new Creator
    Identifier {.Identifier }[IdentifierSuffix]
    BasicType BracketsOpt .class
    void.class
 */
primary
    : parExpression
    | THIS arguments? // this() or this.method()
    | SUPER superSuffix
    | literal
    | NEW creator // constructor invocation
    | Identifier (PERIOD Identifier)* identifierSuffix?
    | basicType bracketsOpt PERIOD CLASS
    | VOID PERIOD CLASS
    ;

/* Identifier Suffix
IdentifierSuffix:
    [ ( ] BracketsOpt . class | Expression])
    Arguments
    .(class | this | super Arguments | new InnerCreator)
*/
identifierSuffix
    : OPEN_BRACKET (bracketsOpt PERIOD CLASS | expression) CLOSE_BRACKET
    | arguments //method invocation
    | PERIOD (CLASS | THIS | SUPER arguments | NEW innerCreator)
    ;

/*  Selectors (w method calls)
 Selector:=
    Identifier [Arguments]
    .this
    .super SuperSuffix
    .new InnerCreator
    [Expression]
*/
selector
    : PERIOD Identifier arguments? // method invocation
    | PERIOD THIS
    | PERIOD SUPER superSuffix
    | PERIOD NEW innerCreator
    | OPEN_BRACKET expression CLOSE_BRACKET
    ;

superSuffix
    : arguments // super() constructor
    | PERIOD Identifier arguments? // super.method()
    ;

// The actual parameter list for method calls
arguments
    : OPEN_PARENTHESIS (expression (COMMA expression)*)? CLOSE_PARENTHESIS
    ;

// Creator - (Constructor invocations)
creator
    : qualifiedIdentifier (arrayCreatorRest | classCreatorRest)
    | basicType arrayCreatorRest
    ;

innerCreator
    : Identifier classCreatorRest
    ;

arrayCreatorRest
    : OPEN_BRACKET
      ( CLOSE_BRACKET bracketsOpt arrayInitializer
      | expression CLOSE_BRACKET (OPEN_BRACKET expression CLOSE_BRACKET)* bracketsOpt
      )
    ;

classCreatorRest
    : arguments classBody?
    ;

// Literals
literal
    : IntegerLiteral
    | FloatingPointLiteral
    | CharacterLiteral
    | StringLiteral
    | BooleanLiteral
    | NullLiteral
    ;
