Definitions.

INT        = [0-9]+
FLOAT      = [0-9\.]+
KEYWORD = (SG_|BO_)
IDENTIFIER = [a-zA-Z0-9_]+
STRING = "[^"\\]*(\\.[^"\\]*)*"
WHITESPACE = [\s\t\n\r]+


Rules.

{INT}                   : {token, {int, TokenLine, TokenChars}}.
{FLOAT}                   : {token, {int, TokenLine, TokenChars}}.
{KEYWORD}                : {token, {keyword, TokenLine, to_binary(parse_string(TokenChars))}}.
{IDENTIFIER}            : {token, {identifier, TokenLine, to_binary(TokenChars)}}.
{STRING}                : {token, {string, TokenLine, to_binary(parse_string(TokenChars))}}.
{ASSIGNMENT}            : {token, {assign, TokenLine, TokenChars}}.
{WHITESPACE}            : skip_token.


\[                      : {token, {'[', TokenLine}}.
\]                      : {token, {']', TokenLine}}.
\(                      : {token, {'(', TokenLine}}.
\)                      : {token, {')', TokenLine}}.
\,                      : {token, {',', TokenLine}}.
:                       : {token, {':', TokenLine}}.
;                       : {token, {':', TokenLine}}.
-                       : {token, {'-', TokenLine}}.
\+                       : {token, {'+', TokenLine}}.
\|                      : {token, {'|', TokenLine}}.
\@                      : {token, {'@', TokenLine}}.



Erlang code.

to_binary(Chars) ->
  list_to_binary(Chars).

unescape([$\\,$\"|Cs]) -> [$\"|unescape(Cs)];
unescape([$\\,$\\|Cs]) -> [$\\|unescape(Cs)];
unescape([$\\,$/|Cs]) -> [$/|unescape(Cs)];
unescape([$\\,$b|Cs]) -> [$\b|unescape(Cs)];
unescape([$\\,$f|Cs]) -> [$\f|unescape(Cs)];
unescape([$\\,$n|Cs]) -> [$\n|unescape(Cs)];
unescape([$\\,$r|Cs]) -> [$\r|unescape(Cs)];
unescape([$\\,$t|Cs]) -> [$\t|unescape(Cs)];
unescape([$\\,$u,C0,C1,C2,C3|Cs]) ->
    C = dehex(C3) bor
  (dehex(C2) bsl 4) bor
  (dehex(C1) bsl 8) bor
  (dehex(C0) bsl 12),
    [C|unescape(Cs)];
unescape([$"|Cs]) -> unescape(Cs);
unescape([C|Cs]) -> [C|unescape(Cs)];
unescape([]) -> [].


dehex(C) when C >= $0, C =< $9 -> C - $0;
dehex(C) when C >= $a, C =< $f -> C - $a + 10;
dehex(C) when C >= $A, C =< $F -> C - $A + 10.

parse_string(StringChars) ->
  unescape(StringChars).
