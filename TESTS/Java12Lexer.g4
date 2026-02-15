lexer grammar Java12Lexer;

// ============================================================
// Keywords (Java 1.2)
// ============================================================
ABSTRACT     : 'abstract';
BOOLEAN      : 'boolean';
BREAK        : 'break';
BYTE         : 'byte';
CASE         : 'case';
CATCH        : 'catch';
CHAR         : 'char';
CLASS        : 'class';
CONTINUE     : 'continue';
DEFAULT      : 'default';
DO           : 'do';
DOUBLE       : 'double';
ELSE         : 'else';
EXTENDS      : 'extends';
FINAL        : 'final';
FINALLY      : 'finally';
FLOAT        : 'float';
FOR          : 'for';
IF           : 'if';
IMPLEMENTS   : 'implements';
IMPORT       : 'import';
INSTANCEOF   : 'instanceof';
INT          : 'int';
INTERFACE    : 'interface';
LONG         : 'long';
NATIVE       : 'native';
NEW          : 'new';
PACKAGE      : 'package';
PRIVATE      : 'private';
PROTECTED    : 'protected';
PUBLIC       : 'public';
RETURN       : 'return';
SHORT        : 'short';
STATIC       : 'static';
STRICTFP     : 'strictfp';
SUPER        : 'super';
SWITCH       : 'switch';
SYNCHRONIZED : 'synchronized';
THIS         : 'this';
THROW        : 'throw';
THROWS       : 'throws';
TRANSIENT    : 'transient';
TRY          : 'try';
VOID         : 'void';
VOLATILE     : 'volatile';
WHILE        : 'while';

// ============================================================
// Literals
// ============================================================
IntegerLiteral
    : DecimalIntegerLiteral
    | HexIntegerLiteral
    | OctalIntegerLiteral
    ;

fragment DecimalIntegerLiteral : ('0' | [1-9] [0-9]*) [lL]? ;
fragment HexIntegerLiteral     : '0' [xX] [0-9a-fA-F]+ [lL]? ;
fragment OctalIntegerLiteral   : '0' [0-7]+ [lL]? ;

FloatingPointLiteral
    : [0-9]+ '.' [0-9]* ExponentPart? FloatTypeSuffix?
    | '.' [0-9]+ ExponentPart? FloatTypeSuffix?
    | [0-9]+ ExponentPart FloatTypeSuffix?
    | [0-9]+ FloatTypeSuffix
    ;

fragment ExponentPart    : [eE] [+-]? [0-9]+ ;
fragment FloatTypeSuffix : [fFdD] ;

BooleanLiteral : 'true' | 'false' ;
CharacterLiteral : '\'' (EscapeSequence | ~['\\]) '\'' ;
StringLiteral    : '"' (EscapeSequence | ~["\\])* '"' ;
NullLiteral      : 'null' ;

fragment EscapeSequence
    : '\\' [btnfr"'\\]
    | '\\' [0-3]? [0-7] [0-7]?   // octal escape
    | '\\' 'u'+ [0-9a-fA-F] [0-9a-fA-F] [0-9a-fA-F] [0-9a-fA-F] // unicode escape
    ;

// ============================================================
// Separators and Operators
// ============================================================
LPAREN    : '(';
RPAREN    : ')';
LBRACE    : '{';
RBRACE    : '}';
LBRACKET  : '[';
RBRACKET  : ']';
SEMI      : ';';
COMMA     : ',';
DOT       : '.';

ASSIGN      : '=';
GT          : '>';
LT          : '<';
BANG        : '!';
TILDE       : '~';
QUESTION    : '?';
COLON       : ':';
EQUAL       : '==';
LE          : '<=';
GE          : '>=';
NOTEQUAL    : '!=';
AND         : '&&';
OR          : '||';
INC         : '++';
DEC         : '--';
ADD         : '+';
SUB         : '-';
MUL         : '*';
DIV         : '/';
BITAND      : '&';
BITOR       : '|';
CARET       : '^';
MOD         : '%';

ADD_ASSIGN  : '+=';
SUB_ASSIGN  : '-=';
MUL_ASSIGN  : '*=';
DIV_ASSIGN  : '/=';
AND_ASSIGN  : '&=';
OR_ASSIGN   : '|=';
XOR_ASSIGN  : '^=';
MOD_ASSIGN  : '%=';
LSHIFT_ASSIGN : '<<=';
RSHIFT_ASSIGN : '>>=';
URSHIFT_ASSIGN: '>>>=';

LSHIFT  : '<<';
// Note: >> and >>> are handled contextually or via tokens
RSHIFT  : '>>';
URSHIFT : '>>>';

// ============================================================
// Identifiers
// ============================================================
Identifier : JavaLetter JavaLetterOrDigit* ;

fragment JavaLetter : [a-zA-Z$_] ;
fragment JavaLetterOrDigit : [a-zA-Z0-9$_] ;

// ============================================================
// Whitespace and Comments
// ============================================================
WS           : [ \t\r\n\u000C]+ -> skip ;
COMMENT      : '/*' .*? '*/' -> skip ;
LINE_COMMENT : '//' ~[\r\n]* -> skip ;
