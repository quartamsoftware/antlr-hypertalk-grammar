/*

The MIT License (MIT)

Copyright (c) 2013 Quartam Software / Jan Schenkel

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

AND : [Aa][Nn][Dd] ;
DIV : [Dd][Ii][Vv] ;
DO : [Dd][Oo] ;
DOWN : [Dd][Oo][Ww][Nn] ;
ELSE : [Ee][Ll][Ss][Ee] ;
END : [Ee][Nn][Dd] ;
EXIT: [Ee][Xx][Ii][Tt] ;
FOR: [Ff][Oo][Rr] ;
FOREVER : [Ff][Oo][Rr][Ee][Vv][Ee][Rr] ;
FUNCTION : [Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn] ;
GLOBAL : [Gg][Ll][Oo][Bb][Aa][Ll] ;
HYPERCARD : [Hh][Yy][Pp][Ee][Rr][Cc][Aa][Rr][Dd] ;
IF : [Ii][Ff] ;
IS : [Ii][Ss] ;
MOD : [Mm][Oo][Dd] ;
NEXT : [Nn][Ee][Xx][Tt] ;
NOT : [Nn][Oo][Tt] ;
ON : [Oo][Nn] ;
OR : [Oo][Rr] ;
REPEAT : [Rr][Ee][Pp][Ee][Aa][Tt] ;
THEN : [Tt][Hh][Ee][Nn] ;
TIMES : [Tt][Ii][Mm][Ee][Ss] ;
TO : [Tt][Oo] ;
UNTIL : [Uu][Nn][Tt][Ii][Ll] ;
WITH : [Ww][Ii][Tt][Hh] ;
WHILE : [Ww][Hh][Ii][Ll][Ee] ;

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

fragment DIGIT : '0'..'9' ;
fragment CHARSEQUENCE : ~["\r\n]+ ;

COMMENT
    : COMMENT_SYMBOL ~[\r\n]* -> skip ;
CONTINUATION
    : CONTINUATION_SYMBOL ~[\r\n]* NEWLINE -> skip ;
WHITESPACE
    : [ \t]+ -> skip ;
