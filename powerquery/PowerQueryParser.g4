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
 * Power Query M formula language — syntactic grammar.
 *
 * Rule names follow the productions of the "M Language Consolidated Grammar"
 * (https://learn.microsoft.com/powerquery-m/m-spec-consolidated-grammar), with
 * '-' written as '_'. Departures from the specification, each matching what the
 * Power Query product accepts:
 *   - the null-coalescing operator '??' binds looser than 'or' (it is in the
 *     spec's punctuator list but in none of its productions);
 *   - 'try ... catch (e) => ...' is supported;
 *   - generalized identifiers (record field names and field selectors such as
 *     [Sales Amount] or [1st Quarter]) are a sequence of identifier, keyword and
 *     number tokens; the spec's "separated only by blanks" cannot be checked
 *     without target code, so a comment between two parts is accepted;
 *   - a table type may take its row type from an expression: type table (t);
 *   - binary operators are written left-recursively, which gives the left
 *     associativity the spec's semantics require.
 *
 * Inherent ambiguity: in a type position, 'number', '{number}' or '[a = text]'
 * can be read either as a type or as an expression; primary_type is tried first.
 */

// $antlr-format alignTrailingComments true, columnLimit 150, minEmptyLines 1, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine false, allowShortBlocksOnASingleLine true, alignSemicolons hanging, alignColons hanging

parser grammar PowerQueryParser;

options {
    tokenVocab = PowerQueryLexer;
}

// ---- Documents ----

document
    : (section_document | expression_document) EOF
    ;

section_document
    : literal_attributes? SECTION section_name SEMICOLON section_member*
    ;

section_name
    : identifier
    ;

section_member
    : literal_attributes? SHARED? section_member_name EQUALS expression SEMICOLON
    ;

section_member_name
    : identifier
    ;

expression_document
    : expression
    ;

// ---- Expressions ----

expression
    : each_expression
    | function_expression
    | let_expression
    | if_expression
    | error_raising_expression
    | error_handling_expression
    | null_coalescing_expression
    ;

null_coalescing_expression
    : logical_or_expression (NULL_COALESCING logical_or_expression)*
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR logical_and_expression
    ;

logical_and_expression
    : is_expression
    | logical_and_expression AND is_expression
    ;

is_expression
    : as_expression
    | is_expression IS primitive_or_nullable_primitive_type
    ;

as_expression
    : equality_expression
    | as_expression AS primitive_or_nullable_primitive_type
    ;

equality_expression
    : relational_expression
    | equality_expression (EQUALS | NOT_EQUAL) relational_expression
    ;

relational_expression
    : additive_expression
    | relational_expression (LESS_THAN | GREATER_THAN | LESS_THAN_OR_EQUAL | GREATER_THAN_OR_EQUAL) additive_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression (PLUS | MINUS | AMPERSAND) multiplicative_expression
    ;

multiplicative_expression
    : metadata_expression
    | multiplicative_expression (ASTERISK | DIVISION) metadata_expression
    ;

metadata_expression
    : unary_expression
    | metadata_expression META unary_expression
    ;

unary_expression
    : type_expression
    | PLUS unary_expression
    | MINUS unary_expression
    | NOT unary_expression
    ;

// ---- Primary expressions ----

// Alternatives are labelled so each form gets its own parse-tree context
// (e.g. Invoke_expressionContext); the four postfix forms are the spec's
// invoke-, item-access-, field-access- and projection expressions.
primary_expression
    : literal_expression                                                     # literal_primary
    | list_expression                                                        # list_primary
    | record_expression                                                      # record_primary
    | identifier_expression                                                  # identifier_primary
    | section_access_expression                                              # section_access_primary
    | parenthesized_expression                                               # parenthesized_primary
    | implicit_target_field_selection                                        # implicit_field_selection_primary
    | implicit_target_projection                                             # implicit_projection_primary
    | not_implemented_expression                                             # not_implemented_primary
    | primary_expression OPEN_PAREN argument_list? CLOSE_PAREN               # invoke_expression
    | primary_expression OPEN_BRACE item_selector CLOSE_BRACE QUESTION_MARK? # item_access_expression
    | primary_expression field_selector                                      # field_access_expression
    | primary_expression required_projection QUESTION_MARK?                  # projection_expression
    ;

literal_expression
    : literal
    ;

literal
    : logical_literal
    | number_literal
    | text_literal
    | null_literal
    | verbatim_literal
    ;

logical_literal
    : TRUE
    | FALSE
    ;

number_literal
    : DECIMAL_NUMBER_LITERAL
    | HEXADECIMAL_NUMBER_LITERAL
    ;

text_literal
    : TEXT_LITERAL
    ;

null_literal
    : NULL_
    ;

verbatim_literal
    : VERBATIM_LITERAL
    ;

identifier_expression
    : identifier_reference
    ;

identifier_reference
    : exclusive_identifier_reference
    | inclusive_identifier_reference
    ;

exclusive_identifier_reference
    : identifier
    | predefined_identifier
    ;

inclusive_identifier_reference
    : AT identifier
    ;

// The '#'-keywords name library values (#table, #date, #shared, ...) and are
// used as expressions.
predefined_identifier
    : HASH_BINARY
    | HASH_DATE
    | HASH_DATETIME
    | HASH_DATETIMEZONE
    | HASH_DURATION
    | HASH_INFINITY
    | HASH_NAN
    | HASH_SECTIONS
    | HASH_SHARED
    | HASH_TABLE
    | HASH_TIME
    ;

section_access_expression
    : identifier BANG identifier
    ;

parenthesized_expression
    : OPEN_PAREN expression CLOSE_PAREN
    ;

not_implemented_expression
    : ELLIPSIS
    ;

argument_list
    : expression (COMMA expression)*
    ;

list_expression
    : OPEN_BRACE item_list? CLOSE_BRACE
    ;

item_list
    : item (COMMA item)*
    ;

item
    : expression (DOT_DOT expression)?
    ;

record_expression
    : OPEN_BRACKET field_list? CLOSE_BRACKET
    ;

field_list
    : field (COMMA field)*
    ;

field
    : field_name EQUALS expression
    ;

field_name
    : generalized_identifier
    | QUOTED_IDENTIFIER
    ;

item_selector
    : expression
    ;

field_selector
    : required_field_selector
    | optional_field_selector
    ;

required_field_selector
    : OPEN_BRACKET field_name CLOSE_BRACKET
    ;

optional_field_selector
    : OPEN_BRACKET field_name CLOSE_BRACKET QUESTION_MARK
    ;

implicit_target_field_selection
    : field_selector
    ;

required_projection
    : OPEN_BRACKET required_selector_list CLOSE_BRACKET
    ;

required_selector_list
    : required_field_selector (COMMA required_field_selector)*
    ;

implicit_target_projection
    : required_projection QUESTION_MARK?
    ;

// ---- Functions, each, let, if ----

function_expression
    : OPEN_PAREN parameter_list? CLOSE_PAREN return_type? FAT_ARROW function_body
    ;

function_body
    : expression
    ;

parameter_list
    : fixed_parameter_list (COMMA optional_parameter_list)?
    | optional_parameter_list
    ;

fixed_parameter_list
    : parameter (COMMA parameter)*
    ;

optional_parameter_list
    : optional_parameter (COMMA optional_parameter)*
    ;

optional_parameter
    : OPTIONAL parameter
    ;

parameter
    : parameter_name primitive_or_nullable_primitive_type_assertion?
    ;

parameter_name
    : identifier
    ;

return_type
    : primitive_or_nullable_primitive_type_assertion
    ;

primitive_or_nullable_primitive_type_assertion
    : AS primitive_or_nullable_primitive_type
    ;

each_expression
    : EACH function_body
    ;

let_expression
    : LET variable_list IN expression
    ;

variable_list
    : variable (COMMA variable)*
    ;

variable
    : variable_name EQUALS expression
    ;

variable_name
    : identifier
    ;

if_expression
    : IF expression THEN expression ELSE expression
    ;

// ---- Types ----

type_expression
    : primary_expression
    | TYPE primary_type
    ;

type_
    : primary_type
    | primary_expression
    ;

primary_type
    : primitive_or_nullable_primitive_type
    | record_type
    | list_type
    | function_type
    | table_type
    | nullable_type
    ;

primitive_or_nullable_primitive_type
    : NULLABLE? primitive_type
    ;

primitive_type
    : ANY
    | ANYNONNULL
    | BINARY
    | DATE
    | DATETIME
    | DATETIMEZONE
    | DURATION
    | FUNCTION
    | LIST
    | LOGICAL
    | NONE
    | NULL_
    | NUMBER
    | RECORD
    | TABLE
    | TEXT
    | TIME
    | TYPE
    ;

record_type
    : OPEN_BRACKET ELLIPSIS CLOSE_BRACKET
    | OPEN_BRACKET field_specification_list? CLOSE_BRACKET
    | OPEN_BRACKET field_specification_list COMMA ELLIPSIS CLOSE_BRACKET
    ;

field_specification_list
    : field_specification (COMMA field_specification)*
    ;

field_specification
    : OPTIONAL? field_name field_type_specification?
    ;

field_type_specification
    : EQUALS type_
    ;

list_type
    : OPEN_BRACE type_ CLOSE_BRACE
    ;

function_type
    : FUNCTION OPEN_PAREN parameter_specification_list? CLOSE_PAREN return_type
    ;

parameter_specification_list
    : required_parameter_specification_list (COMMA optional_parameter_specification_list)?
    | optional_parameter_specification_list
    ;

required_parameter_specification_list
    : parameter_specification (COMMA parameter_specification)*
    ;

optional_parameter_specification_list
    : optional_parameter_specification (COMMA optional_parameter_specification)*
    ;

optional_parameter_specification
    : OPTIONAL parameter_specification
    ;

parameter_specification
    : parameter_name type_assertion
    ;

type_assertion
    : AS type_
    ;

// 'table' followed by an expression (type table (Type.ForRecord(r, false))) is
// accepted by Power Query and used in Microsoft's own connector samples.
table_type
    : TABLE row_type
    | TABLE primary_expression
    ;

row_type
    : OPEN_BRACKET field_specification_list? CLOSE_BRACKET
    ;

nullable_type
    : NULLABLE type_
    ;

// ---- Errors ----

error_raising_expression
    : ERROR expression
    ;

error_handling_expression
    : TRY protected_expression error_handler?
    ;

protected_expression
    : expression
    ;

error_handler
    : otherwise_clause
    | catch_clause
    ;

otherwise_clause
    : OTHERWISE expression
    ;

catch_clause
    : CATCH catch_function
    ;

catch_function
    : OPEN_PAREN parameter_name? CLOSE_PAREN FAT_ARROW function_body
    ;

// ---- Literal attributes ----

literal_attributes
    : record_literal
    ;

record_literal
    : OPEN_BRACKET literal_field_list? CLOSE_BRACKET
    ;

literal_field_list
    : literal_field (COMMA literal_field)*
    ;

literal_field
    : field_name EQUALS any_literal
    ;

list_literal
    : OPEN_BRACE literal_item_list? CLOSE_BRACE
    ;

literal_item_list
    : any_literal (COMMA any_literal)*
    ;

any_literal
    : record_literal
    | list_literal
    | logical_literal
    | number_literal
    | text_literal
    | null_literal
    ;

// ---- Identifiers ----

identifier
    : REGULAR_IDENTIFIER
    | QUOTED_IDENTIFIER
    | contextual_keyword
    ;

// Words the lexer tokenizes for the grammar's sake but M does not reserve.
contextual_keyword
    : CATCH
    | OPTIONAL
    | NULLABLE
    | ANY
    | ANYNONNULL
    | BINARY
    | DATE
    | DATETIME
    | DATETIMEZONE
    | DURATION
    | FUNCTION
    | LIST
    | LOGICAL
    | NONE
    | NUMBER
    | RECORD
    | TABLE
    | TEXT
    | TIME
    ;

// A field name: any mix of identifiers, keywords and numbers, e.g.
// [Sales Amount], [1st Quarter], [if], [Column1.1].
generalized_identifier
    : generalized_identifier_part+
    ;

generalized_identifier_part
    : REGULAR_IDENTIFIER
    | contextual_keyword
    | keyword
    | DECIMAL_NUMBER_LITERAL
    ;

keyword
    : AND
    | AS
    | EACH
    | ELSE
    | ERROR
    | FALSE
    | IF
    | IN
    | IS
    | LET
    | META
    | NOT
    | NULL_
    | OR
    | OTHERWISE
    | SECTION
    | SHARED
    | THEN
    | TRUE
    | TRY
    | TYPE
    ;