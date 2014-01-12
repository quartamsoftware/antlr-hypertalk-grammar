/*

The MIT License (MIT)

Copyright (c) 2013-2014 Quartam Software / Jan Schenkel

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


grammar HyperTalk;


/* --- PARSER RULES --- */

script
    : ( handler | NEWLINE )* EOF;

handler
    : ( ON | FUNCTION ) IDENTIFIER identifierList? NEWLINE+
          statementList
      END IDENTIFIER ;

statementList
    : ( statement NEWLINE+ )* ;

statement
    : talkStatement
    | talkBlock
    | userStatement
    ;

/* PARSER: built-in command rules */

talkStatement
    : doStatement
    | exitStatement
    | globalStatement
    | nextStatement
    ;

doStatement
    : DO expression ;

exitStatement
    : EXIT ( REPEAT | IDENTIFIER | TO HYPERCARD ) ;

globalStatement
    : GLOBAL identifierList ;

nextStatement
    : NEXT REPEAT ;

/* PARSER: block rules */

talkBlock
    : ifBlock
    | repeatBlock
    ;

/* -> IF block rules */

ifBlock
    : IF expression NEWLINE?
      THEN ( singleThenBlock | NEWLINE multiThenBlock ) ;

singleThenBlock
    : statement ( NEWLINE? elseBlock )? ;

multiThenBlock
    : statementList ( END IF | elseBlock ) ;

elseBlock
    : ELSE ( statement | NEWLINE statementList END IF ) ;

/* -> REPEAT block rules */

repeatBlock
    : REPEAT ( FOREVER | repeatDuration | repeatCount | repeatWith ) NEWLINE
          statementList
      END REPEAT ;

repeatDuration
    : ( UNTIL | WHILE ) expression ;

repeatCount
    : FOR? expression TIMES? ;

repeatWith
    : WITH IDENTIFIER EQ_SYMBOL expression DOWN? TO expression ;

/* PARSER: userStatement rules */

userStatement
    : IDENTIFIER actualParameterList? ;

/* PARSER: expression rules */

expression
    : ( NOT | MINUS_SYMBOL ) expression                                        # UnaryExpression
    | expression CARET_SYMBOL<assoc=right> expression                          # ExponentiationExpression
    | expression 
      ( DIV | MOD | STAR_SYMBOL | SLASH_SYMBOL )
      expression                                                               # MultiplicationExpression
    | expression 
      ( PLUS_SYMBOL | MINUS_SYMBOL )
      expression                                                               # AdditionExpression
    | expression 
      ( AMP_SYMBOL | AMPAMP_SYMBOL )
      expression                                                               # ConcatenationExpression
    | expression 
      ( GE_SYMBOL | GT_SYMBOL | LE_SYMBOL | LT_SYMBOL )
      expression                                                               # RelationalExpression
    | expression 
      ( IS | IS NOT | EQ_SYMBOL | NE_SYMBOL )
      expression                                                               # EquivalenceExpression
    | expression AND expression                                                # AndExpression
    | expression OR expression                                                 # OrExpression
    | LPAREN expression RPAREN                                                 # NestedExpression
    | IDENTIFIER LPAREN actualParameterList? RPAREN                            # UserFuncExpression
    | literal                                                                  # LiteralExpression
    | IDENTIFIER                                                               # IdentiferExpression
    ;

literal
    : STRING
    | NUMBER
    ;


/* PARSER: miscellanea */ 

actualParameterList
    : expression ( COMMA_SYMBOL expression )* ;

identifierList
    : IDENTIFIER ( COMMA_SYMBOL IDENTIFIER )* ;


/* --- LEXER rules --- */

/* LEXER: keyword rules */

AND : A N D ;
DIV : D I V ;
DO : D O ;
DOWN : D O W N ;
ELSE : E L S E ;
END : E N D ;
EXIT: E X I T ;
FOR: F O R ;
FOREVER : F O R E V E R ;
FUNCTION : F U N C T I O N ;
GLOBAL : G L O B A L ;
HYPERCARD : H Y P E R C A R D ;
IF : I F ;
IS : I S ;
MOD : M O D ;
NEXT : N E X T ;
NOT : N O T ;
ON : O N ;
OR : O R ;
REPEAT : R E P E A T ;
THEN : T H E N ;
TIMES : T I M E S ;
TO : T O ;
UNTIL : U N T I L ;
WITH : W I T H ;
WHILE : W H I L E ;

/* LEXER: symbol rules */

AMP_SYMBOL : '&' ;
AMPAMP_SYMBOL : '&&' ;
CARET_SYMBOL : '^' ;
COMMA_SYMBOL : ',' ;
COMMENT_SYMBOL : '--' ;
CONTINUATION_SYMBOL : '\\' | '\u00AC' ;
EQ_SYMBOL : '=' ;
GE_SYMBOL : '>=' | '\u2265' ;
GT_SYMBOL : '>' ;
LE_SYMBOL : '<=' | '\u2264' ;
LT_SYMBOL : '<' ;
MINUS_SYMBOL : '-' ;
NE_SYMBOL : '<>' | '\u2260';
PLUS_SYMBOL : '+' ;
STAR_SYMBOL : '*' ;
SLASH_SYMBOL : '/' ;

/* LEXER: miscellanea */

LPAREN : '(' ;
RPAREN : ')' ;

NEWLINE
    : ( '\r\n' | '\n' | '\r' ) ;

IDENTIFIER
    : ( 'a'..'z' | 'A'..'Z' ) ( 'a'..'z' | 'A'..'Z' | DIGIT | '_' )* ;
NUMBER 
    : ( '0' | '1'..'9' DIGIT*) ('.' DIGIT+ )? ;
STRING
    : '"' CHARSEQUENCE? '"' ;
COMMENT
    : COMMENT_SYMBOL ~[\r\n]* -> skip ;
CONTINUATION
    : CONTINUATION_SYMBOL ~[\r\n]* NEWLINE -> skip ;
WHITESPACE
    : [ \t]+ -> skip ;

/* LEXER: fragments */

fragment DIGIT : '0'..'9' ;
fragment CHARSEQUENCE : ~["\r\n]+ ;

/* case insensitive lexer matching */
fragment A:('a'|'A');
fragment B:('b'|'B');
fragment C:('c'|'C');
fragment D:('d'|'D');
fragment E:('e'|'E');
fragment F:('f'|'F');
fragment G:('g'|'G');
fragment H:('h'|'H');
fragment I:('i'|'I');
fragment J:('j'|'J');
fragment K:('k'|'K');
fragment L:('l'|'L');
fragment M:('m'|'M');
fragment N:('n'|'N');
fragment O:('o'|'O');
fragment P:('p'|'P');
fragment Q:('q'|'Q');
fragment R:('r'|'R');
fragment S:('s'|'S');
fragment T:('t'|'T');
fragment U:('u'|'U');
fragment V:('v'|'V');
fragment W:('w'|'W');
fragment X:('x'|'X');
fragment Y:('y'|'Y');
fragment Z:('z'|'Z');
