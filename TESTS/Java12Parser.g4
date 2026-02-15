parser grammar Java12Parser;

options { tokenVocab=Java12Lexer; }

// ============================================================
// Compilation Unit (JLS2 §7.3)
// ============================================================
compilationUnit
    : packageDeclaration? importDeclaration* typeDeclaration* EOF
    ;

packageDeclaration
    : PACKAGE qualifiedName SEMI
    ;

importDeclaration
    : IMPORT qualifiedName (DOT MUL)? SEMI
    ;

typeDeclaration
    : classDeclaration
    | interfaceDeclaration
    | SEMI
    ;

// ============================================================
// Class Declaration (JLS2 §8.1)
// ============================================================
classDeclaration
    : modifier* CLASS Identifier (EXTENDS classType)? (IMPLEMENTS classTypeList)? classBody
    ;

classBody
    : LBRACE classBodyDeclaration* RBRACE
    ;

classBodyDeclaration
    : SEMI
    | STATIC? block                          // static initializer or instance initializer
    | modifier* memberDeclaration
    ;

memberDeclaration
    : methodDeclaration
    | fieldDeclaration
    | constructorDeclaration
    | classDeclaration
    | interfaceDeclaration
    ;

// ============================================================
// Field Declaration (JLS2 §8.3)
// ============================================================
fieldDeclaration
    : type variableDeclarators SEMI
    ;

variableDeclarators
    : variableDeclarator (COMMA variableDeclarator)*
    ;

variableDeclarator
    : variableDeclaratorId (ASSIGN variableInitializer)?
    ;

variableDeclaratorId
    : Identifier (LBRACKET RBRACKET)*
    ;

variableInitializer
    : arrayInitializer
    | expression
    ;

// ============================================================
// Method Declaration (JLS2 §8.4)
// ============================================================
methodDeclaration
    : (type | VOID) Identifier LPAREN formalParameterList? RPAREN (LBRACKET RBRACKET)*
      (THROWS classTypeList)? (methodBody | SEMI)
    ;

methodBody
    : block
    ;

formalParameterList
    : formalParameter (COMMA formalParameter)*
    ;

formalParameter
    : FINAL? type variableDeclaratorId
    ;

// ============================================================
// Constructor Declaration (JLS2 §8.8)
// ============================================================
constructorDeclaration
    : Identifier LPAREN formalParameterList? RPAREN (THROWS classTypeList)? constructorBody
    ;

constructorBody
    : LBRACE explicitConstructorInvocation? blockStatement* RBRACE
    ;

explicitConstructorInvocation
    : THIS LPAREN argumentList? RPAREN SEMI
    | SUPER LPAREN argumentList? RPAREN SEMI
    | primary DOT SUPER LPAREN argumentList? RPAREN SEMI
    ;

// ============================================================
// Interface Declaration (JLS2 §9.1)
// ============================================================
interfaceDeclaration
    : modifier* INTERFACE Identifier (EXTENDS classTypeList)? interfaceBody
    ;

interfaceBody
    : LBRACE interfaceMemberDeclaration* RBRACE
    ;

interfaceMemberDeclaration
    : constantDeclaration
    | abstractMethodDeclaration
    | classDeclaration
    | interfaceDeclaration
    | SEMI
    ;

constantDeclaration
    : fieldDeclaration
    ;

abstractMethodDeclaration
    : modifier* (type | VOID) Identifier LPAREN formalParameterList? RPAREN (LBRACKET RBRACKET)*
      (THROWS classTypeList)? SEMI
    ;

// ============================================================
// Types (JLS2 §4)
// ============================================================
type
    : primitiveType (LBRACKET RBRACKET)*
    | classOrInterfaceType (LBRACKET RBRACKET)*
    ;

primitiveType
    : BOOLEAN
    | BYTE
    | CHAR
    | SHORT
    | INT
    | LONG
    | FLOAT
    | DOUBLE
    ;

classOrInterfaceType
    : qualifiedName
    ;

classType
    : classOrInterfaceType
    ;

classTypeList
    : classOrInterfaceType (COMMA classOrInterfaceType)*
    ;

// ============================================================
// Blocks and Statements (JLS2 §14)
// ============================================================
block
    : LBRACE blockStatement* RBRACE
    ;

blockStatement
    : localVariableDeclarationStatement
    | classDeclaration
    | statement
    ;

localVariableDeclarationStatement
    : localVariableDeclaration SEMI
    ;

localVariableDeclaration
    : FINAL? type variableDeclarators
    ;

statement
    : block
    | IF LPAREN expression RPAREN statement (ELSE statement)?
    | FOR LPAREN forInit? SEMI expression? SEMI forUpdate? RPAREN statement
    | WHILE LPAREN expression RPAREN statement
    | DO statement WHILE LPAREN expression RPAREN SEMI
    | TRY block catches
    | TRY block catches? FINALLY block
    | SWITCH LPAREN expression RPAREN LBRACE switchBlockStatementGroup* switchLabel* RBRACE
    | SYNCHRONIZED LPAREN expression RPAREN block
    | RETURN expression? SEMI
    | THROW expression SEMI
    | BREAK Identifier? SEMI
    | CONTINUE Identifier? SEMI
    | SEMI
    | Identifier COLON statement                      // labeled statement
    | statementExpression SEMI
    ;

catches
    : catchClause+
    ;

catchClause
    : CATCH LPAREN formalParameter RPAREN block
    ;

switchBlockStatementGroup
    : switchLabel+ blockStatement+
    ;

switchLabel
    : CASE constantExpression COLON
    | DEFAULT COLON
    ;

forInit
    : localVariableDeclaration
    | statementExpressionList
    ;

forUpdate
    : statementExpressionList
    ;

statementExpressionList
    : statementExpression (COMMA statementExpression)*
    ;

statementExpression
    : expression
    ;

constantExpression
    : expression
    ;

// ============================================================
// Expressions (JLS2 §15)
// ============================================================
expression
    : conditionalExpression (assignmentOperator expression)?
    ;

assignmentOperator
    : ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | MUL_ASSIGN
    | DIV_ASSIGN
    | AND_ASSIGN
    | OR_ASSIGN
    | XOR_ASSIGN
    | MOD_ASSIGN
    | LSHIFT_ASSIGN
    | RSHIFT_ASSIGN
    | URSHIFT_ASSIGN
    ;

conditionalExpression
    : conditionalOrExpression (QUESTION expression COLON conditionalExpression)?
    ;

conditionalOrExpression
    : conditionalAndExpression (OR conditionalAndExpression)*
    ;

conditionalAndExpression
    : inclusiveOrExpression (AND inclusiveOrExpression)*
    ;

inclusiveOrExpression
    : exclusiveOrExpression (BITOR exclusiveOrExpression)*
    ;

exclusiveOrExpression
    : andExpression (CARET andExpression)*
    ;

andExpression
    : equalityExpression (BITAND equalityExpression)*
    ;

equalityExpression
    : relationalExpression ((EQUAL | NOTEQUAL) relationalExpression)*
    ;

relationalExpression
    : shiftExpression
      ( (LT | GT | LE | GE) shiftExpression
      | INSTANCEOF type
      )*
    ;

shiftExpression
    : additiveExpression ((LSHIFT | RSHIFT | URSHIFT) additiveExpression)*
    ;

additiveExpression
    : multiplicativeExpression ((ADD | SUB) multiplicativeExpression)*
    ;

multiplicativeExpression
    : unaryExpression ((MUL | DIV | MOD) unaryExpression)*
    ;

unaryExpression
    : INC unaryExpression
    | DEC unaryExpression
    | ADD unaryExpression
    | SUB unaryExpression
    | unaryExpressionNotPlusMinus
    ;

unaryExpressionNotPlusMinus
    : TILDE unaryExpression
    | BANG unaryExpression
    | castExpression
    | postfixExpression
    ;

castExpression
    : LPAREN primitiveType (LBRACKET RBRACKET)* RPAREN unaryExpression
    | LPAREN classOrInterfaceType (LBRACKET RBRACKET)* RPAREN unaryExpressionNotPlusMinus
    ;

postfixExpression
    : primary (   DOT Identifier
                | DOT THIS
                | DOT CLASS
                | DOT NEW innerCreator
                | DOT SUPER LPAREN argumentList? RPAREN  // qualified super invocation
                | LBRACKET expression RBRACKET
                | arguments                               // method invocation
                | INC
                | DEC
              )*
    ;

primary
    : literal
    | THIS
    | SUPER
    | LPAREN expression RPAREN
    | NEW creator
    | classOrInterfaceType DOT CLASS
    | primitiveType (LBRACKET RBRACKET)* DOT CLASS
    | VOID DOT CLASS
    | Identifier
    ;

innerCreator
    : Identifier LPAREN argumentList? RPAREN classBody?
    ;

creator
    : classOrInterfaceType classCreatorRest
    | classOrInterfaceType arrayCreatorRest
    | primitiveType arrayCreatorRest
    ;

classCreatorRest
    : LPAREN argumentList? RPAREN classBody?
    ;

arrayCreatorRest
    : LBRACKET ( RBRACKET (LBRACKET RBRACKET)* arrayInitializer
               | expression RBRACKET (LBRACKET expression RBRACKET)* (LBRACKET RBRACKET)*
              )
    ;

arguments
    : LPAREN argumentList? RPAREN
    ;

argumentList
    : expression (COMMA expression)*
    ;

// ============================================================
// Array Initializer (JLS2 §10.6)
// ============================================================
arrayInitializer
    : LBRACE (variableInitializer (COMMA variableInitializer)* COMMA?)? RBRACE
    ;

// ============================================================
// Modifiers (JLS2 §8.1.1)
// ============================================================
modifier
    : PUBLIC
    | PROTECTED
    | PRIVATE
    | STATIC
    | ABSTRACT
    | FINAL
    | NATIVE
    | SYNCHRONIZED
    | TRANSIENT
    | VOLATILE
    | STRICTFP
    ;

// ============================================================
// Qualified Name
// ============================================================
qualifiedName
    : Identifier (DOT Identifier)*
    ;
