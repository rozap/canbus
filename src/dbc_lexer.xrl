Definitions.

WHITESPACE  = [\s\t]
NEWLINE     = [\n\r]
IDENTIFIER  = [a-zA-Z_][a-zA-Z0-9_]*
INTEGER     = [0-9]+
FLOAT       = [0-9]+\.[0-9]+
STRING      = \"[^\"]*\"
COLON       = :
SEMICOLON   = ;
PIPE        = \|
AT          = @
LBRACKET    = \[
RBRACKET    = \]
LPAREN      = \(
RPAREN      = \)
LBRACE      = \{
RBRACE      = \}
COMMA       = ,
PLUS        = \+
MINUS       = \-

Rules.

VERSION     : {token, {version, TokenLine}}.
NS_        : {token, {new_symbols, TokenLine}}.
BS_        : {token, {bit_timing, TokenLine}}.
BU_        : {token, {nodes, TokenLine}}.
BO_        : {token, {message, TokenLine}}.
SG_        : {token, {signal, TokenLine}}.
CM_        : {token, {comment, TokenLine}}.
BA_DEF_    : {token, {attribute_definition, TokenLine}}.
BA_        : {token, {attribute, TokenLine}}.
VAL_       : {token, {value_definition, TokenLine}}.

{WHITESPACE}+ : skip_token.
{NEWLINE}     : {token, {delimiter, TokenLine}}.
{SEMICOLON}   : {token, {delimiter, TokenLine}}.
{IDENTIFIER}  : {token, {identifier, TokenLine, TokenChars}}.
{INTEGER}     : {token, {integer, TokenLine, list_to_integer(TokenChars)}}.
{FLOAT}       : {token, {float, TokenLine, list_to_float(TokenChars)}}.
{STRING}      : {token, {string, TokenLine, strip_quotes(TokenChars)}}.
{COLON}       : {token, {colon, TokenLine}}.
{PIPE}        : {token, {pipe, TokenLine}}.
{AT}          : {token, {at, TokenLine}}.
{LBRACKET}    : {token, {lbracket, TokenLine}}.
{RBRACKET}    : {token, {rbracket, TokenLine}}.
{LPAREN}      : {token, {lparen, TokenLine}}.
{RPAREN}      : {token, {rparen, TokenLine}}.
{LBRACE}      : {token, {lbrace, TokenLine}}.
{RBRACE}      : {token, {rbrace, TokenLine}}.
{COMMA}       : {token, {comma, TokenLine}}.
{PLUS}        : {token, {plus, TokenLine}}.
{MINUS}       : {token, {minus, TokenLine}}.

Erlang code.

strip_quotes(Chars) ->
    lists:sublist(Chars, 2, length(Chars) - 2).
