Nonterminals
    expr exprs
    keyword
    ident_or_keyword
    version_section
    symbols_section
    nodes_section
    message_section
    comment_section
    signal_list
    signal_definition
    multiplexer
    range
    scale
    unit
    sign
    number
    bit_timing_section
    kw_or_ident_list
    identifier_list delimiters assignment.

Terminals
    version new_symbols bit_timing nodes message signal
    comment attribute_definition attribute value_definition
    identifier integer float string
    colon semicolon pipe at lbracket rbracket
    lparen rparen lbrace rbrace comma plus minus delimiter.



Rootsymbol exprs.
Endsymbol '$end'.

expr -> version_section : '$1'.
expr -> symbols_section : '$1'.
expr -> nodes_section   : '$1'.
expr -> message_section : '$1'.
expr -> comment_section : '$1'.
expr -> bit_timing_section : '$1'.

exprs -> expr : ['$1'].
exprs -> expr delimiters: ['$1'].
exprs -> expr delimiters exprs : ['$1' | '$3'].

delimiters -> delimiter.
delimiters -> delimiter delimiters.

keyword -> version : '$1'.
keyword -> new_symbols : '$1'.
keyword -> bit_timing : '$1'.
keyword -> nodes : '$1'.
keyword -> message : '$1'.
keyword -> signal : '$1'.
keyword -> comment : '$1'.
keyword -> attribute_definition : '$1'.
keyword -> attribute : '$1'.
keyword -> value_definition : '$1'.

assignment -> colon.
assignment -> colon delimiter.

ident_or_keyword -> keyword : strip_meta('$1').
ident_or_keyword -> identifier : strip_meta('$1').

kw_or_ident_list -> ident_or_keyword delimiter : [strip_meta('$1')].
kw_or_ident_list -> ident_or_keyword delimiter kw_or_ident_list : [strip_meta('$1')|'$3'].

identifier_list -> identifier delimiter : [strip_meta('$1')].
identifier_list -> identifier delimiter identifier_list : [strip_meta('$1') | '$3'].

version_section -> version string : {version, strip_meta('$2')}.

symbols_section -> new_symbols assignment kw_or_ident_list : {symbols, '$3'}.

bit_timing_section -> bit_timing assignment integer : {bit_timing, '$2'}.
bit_timing_section -> bit_timing assignment : {bit_timing, nil}.

nodes_section -> nodes assignment : {nodes, nil}.
nodes_section -> nodes assignment integer : {nodes, '$2'}.


comment_section -> comment message integer string :
  {comment, #{
    id => strip_meta('$3'),
    identifier => nil,
    value => strip_meta('$4')
  }}.

comment_section -> comment signal integer identifier string :
  {comment, #{
    id => strip_meta('$3'),
    identifier => strip_meta('$4'),
    value => strip_meta('$5')
  }}.



message_section -> message integer identifier colon integer identifier delimiters signal_list :
    {message, #{
        id => strip_meta('$2'),
        name => strip_meta('$3'),
        size => strip_meta('$5'),
        sender => strip_meta('$6'),
        signals => strip_meta('$8')
    }}.

signal_list -> signal_definition : ['$1'].
signal_list -> signal_definition signal_list : ['$1'|'$2'].

signal_definition -> signal identifier multiplexer colon
                    integer pipe integer at integer sign
                    lparen scale rparen
                    lbracket range rbracket
                    string identifier_list :
    {message, #{
        name => strip_meta('$2'),
        multiplexer => strip_meta('$3'),
        start_bit => strip_meta('$5'),
        size => strip_meta('$7'),
        endianness => strip_meta('$9'),
        sign => strip_meta('$10'),
        scale => strip_meta('$12'),
        range => strip_meta('$15'),
        unit => strip_meta('$17'),
        receivers => strip_meta('$18')
    }}.

signal_definition -> signal identifier colon
                    integer pipe integer % bit_start | size
                    at integer sign % @ endianness sign
                    lparen scale rparen % ( scale )
                    lbracket range rbracket % ( range )
                    string identifier_list :
    #{
        name => strip_meta('$2'),
        multiplexer => strip_meta(nil),
        start_bit => strip_meta('$4'),
        size => strip_meta('$6'),
        endianness => to_endian(strip_meta('$8')),
        sign => '$9',
        scale => strip_meta('$11'),
        range => strip_meta('$14'),
        unit => strip_meta('$16'),
        receivers => strip_meta('$17')
    }.

multiplexer -> delimiter : undefined.
multiplexer -> identifier : {multiplexer, '$1'}.

scale -> number comma number : {strip_meta('$1'), strip_meta('$3')}.
range -> number pipe number : {strip_meta('$1'), strip_meta('$3')}.

unit -> string : '$1'.

sign -> plus : to_sign(strip_meta('$1')).
sign -> minus : to_sign(strip_meta('$1')).

number -> float : '$1'.
number -> integer : '$1'.

Erlang code.

strip_meta({identifier, _LineNo, V}) ->
  V;
strip_meta({integer, _LineNo, V}) ->
  V;
strip_meta({float, _LineNo, V}) ->
  V;
strip_meta({string, _LineNo, V}) ->
  V;
strip_meta(Other) ->
  Other.

to_endian(1) -> little;
to_endian(0) -> big.

to_sign({plus, _}) -> unsigned;
to_sign({minus, _}) -> signed.
