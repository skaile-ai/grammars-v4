/*
 * MIT License
 *
 * Copyright (c) 2026 Skaile GmbH
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Power Query M formula language — lexical grammar.
 *
 * Written from the "M Language Consolidated Grammar" of the Power Query M
 * language specification (https://learn.microsoft.com/powerquery-m/m-spec-consolidated-grammar),
 * with the deviations the Power Query product itself makes, as documented by
 * Microsoft's reference parser (https://github.com/microsoft/powerquery-parser,
 * specification.md):
 *   - after a '.', an identifier continues with any identifier-part character
 *     (so Column1.1 is one identifier);
 *   - 'catch', 'optional', 'nullable' and the primitive type names are not
 *     reserved: they are contextual keywords, usable as identifiers.
 *
 * M is case-sensitive: 'let' is a keyword, 'Let' is an identifier.
 * Whitespace and comments go to the HIDDEN channel so tools can recover them.
 */

// $antlr-format alignTrailingComments true, columnLimit 150, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine true, allowShortBlocksOnASingleLine true, minEmptyLines 0, alignSemicolons ownLine
// $antlr-format alignColons trailing, singleLineOverrulesHangingColon true, alignLexerCommands true, alignLabels true, alignTrailers true

lexer grammar PowerQueryLexer;

// ---- White space and comments ----

// U+FEFF (byte-order mark) is accepted as white space: editors and Excel write it at the start of files.
WHITESPACE: [\p{Zs}\u0009\u000B\u000C\uFEFF]+ -> channel(HIDDEN);

NEW_LINE: ('\r\n' | [\r\n\u0085  ]) -> channel(HIDDEN);

SINGLE_LINE_COMMENT: '//' ~[\r\n\u0085  ]* -> channel(HIDDEN);

DELIMITED_COMMENT: '/*' .*? '*/' -> channel(HIDDEN);

// ---- Keywords (reserved) ----

AND       : 'and';
AS        : 'as';
EACH      : 'each';
ELSE      : 'else';
ERROR     : 'error';
FALSE     : 'false';
IF        : 'if';
IN        : 'in';
IS        : 'is';
LET       : 'let';
META      : 'meta';
NOT       : 'not';
NULL_     : 'null';
OR        : 'or';
OTHERWISE : 'otherwise';
SECTION   : 'section';
SHARED    : 'shared';
THEN      : 'then';
TRUE      : 'true';
TRY       : 'try';
TYPE      : 'type';

HASH_BINARY       : '#binary';
HASH_DATE         : '#date';
HASH_DATETIME     : '#datetime';
HASH_DATETIMEZONE : '#datetimezone';
HASH_DURATION     : '#duration';
HASH_INFINITY     : '#infinity';
HASH_NAN          : '#nan';
HASH_SECTIONS     : '#sections';
HASH_SHARED       : '#shared';
HASH_TABLE        : '#table';
HASH_TIME         : '#time';

// ---- Contextual keywords (not reserved; see PowerQueryParser.identifier) ----

CATCH    : 'catch';
OPTIONAL : 'optional';
NULLABLE : 'nullable';

ANY          : 'any';
ANYNONNULL   : 'anynonnull';
BINARY       : 'binary';
DATE         : 'date';
DATETIME     : 'datetime';
DATETIMEZONE : 'datetimezone';
DURATION     : 'duration';
FUNCTION     : 'function';
LIST         : 'list';
LOGICAL      : 'logical';
NONE         : 'none';
NUMBER       : 'number';
RECORD       : 'record';
TABLE        : 'table';
TEXT         : 'text';
TIME         : 'time';

// ---- Literals ----

HEXADECIMAL_NUMBER_LITERAL: '0' [xX] HEX_DIGIT+;

DECIMAL_NUMBER_LITERAL:
    DECIMAL_DIGITS '.' DECIMAL_DIGITS EXPONENT_PART?
    | '.' DECIMAL_DIGITS EXPONENT_PART?
    | DECIMAL_DIGITS EXPONENT_PART?
;

TEXT_LITERAL: '"' TEXT_LITERAL_CHARACTER* '"';

VERBATIM_LITERAL: '#!"' TEXT_LITERAL_CHARACTER* '"';

// ---- Identifiers ----

QUOTED_IDENTIFIER: '#"' TEXT_LITERAL_CHARACTER* '"';

REGULAR_IDENTIFIER:
    IDENTIFIER_START_CHARACTER IDENTIFIER_PART_CHARACTER* ('.' IDENTIFIER_PART_CHARACTER+)*
;

// ---- Operators and punctuators ----

COMMA                 : ',';
SEMICOLON             : ';';
EQUALS                : '=';
LESS_THAN             : '<';
LESS_THAN_OR_EQUAL    : '<=';
GREATER_THAN          : '>';
GREATER_THAN_OR_EQUAL : '>=';
NOT_EQUAL             : '<>';
PLUS                  : '+';
MINUS                 : '-';
ASTERISK              : '*';
DIVISION              : '/';
AMPERSAND             : '&';
OPEN_PAREN            : '(';
CLOSE_PAREN           : ')';
OPEN_BRACKET          : '[';
CLOSE_BRACKET         : ']';
OPEN_BRACE            : '{';
CLOSE_BRACE           : '}';
AT                    : '@';
QUESTION_MARK         : '?';
NULL_COALESCING       : '??';
FAT_ARROW             : '=>';
DOT_DOT               : '..';
ELLIPSIS              : '...';
BANG                  : '!';

// ---- Fragments ----

fragment DECIMAL_DIGITS : [0-9]+;
fragment HEX_DIGIT      : [0-9a-fA-F];
fragment EXPONENT_PART  : [eE] [+-]? DECIMAL_DIGITS;

// A text character is anything but '"'; '""' is an escaped quote and '#(...)' a
// character escape sequence. A '#' not followed by a valid escape stays a plain
// character: the lexer cannot look ahead without target code, so a malformed
// escape such as "#(bogus)" is accepted as text.
fragment TEXT_LITERAL_CHARACTER: ~["#] | '""' | CHARACTER_ESCAPE_SEQUENCE | '#';

fragment CHARACTER_ESCAPE_SEQUENCE : '#(' ESCAPE_SEQUENCE_LIST ')';
fragment ESCAPE_SEQUENCE_LIST      : SINGLE_ESCAPE_SEQUENCE (',' SINGLE_ESCAPE_SEQUENCE)*;
fragment SINGLE_ESCAPE_SEQUENCE:
    HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    | HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    | 'cr'
    | 'lf'
    | 'tab'
    | '#'
;

fragment IDENTIFIER_START_CHARACTER: LETTER_CHARACTER | '_';

fragment IDENTIFIER_PART_CHARACTER:
    LETTER_CHARACTER
    | [\p{Nd}]
    | [\p{Pc}] // includes '_'
    | [\p{Mn}\p{Mc}]
    | [\p{Cf}]
;

fragment LETTER_CHARACTER: [\p{Lu}\p{Ll}\p{Lt}\p{Lm}\p{Lo}\p{Nl}];