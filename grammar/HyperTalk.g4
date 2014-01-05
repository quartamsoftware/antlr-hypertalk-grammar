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
    : IDENTIFIER LPAREN actualParameterList? RPAREN                           # UserFuncExpression
    | literal                                                                 # LiteralExpression
    | IDENTIFIER                                                              # IdentiferExpression
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

DO : 'do' ;
DOWN : 'down' ;
ELSE : 'else' ;
END : 'end' ;
EXIT: 'exit' ;
FOR: 'for' ;
FOREVER : 'forever' ;
FUNCTION : 'function' ;
GLOBAL : 'global' ;
HYPERCARD : 'hypercard' ;
IF : 'if' ;
NEXT : 'next' ;
ON : 'on' ;
OR : 'or' ;
REPEAT : 'repeat' ;
THEN : 'then' ;
TIMES : 'times' ;
TO : 'to' ;
UNTIL : 'until' ;
WITH : 'with' ;
WHILE : 'while' ;

/* LEXER: symbol rules */

COMMA_SYMBOL : ',' ;
COMMENT_SYMBOL : '--' ;
CONTINUATION_SYMBOL : '\\' | '\u00AC' ;
EQ_SYMBOL : '=' ;

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
