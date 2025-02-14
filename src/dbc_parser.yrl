Nonterminals
    expr exprs
    keyword
    ident_or_keyword
    version_section
    symbols_section
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

exprs -> expr : ['$1'].
exprs -> expr delimiters : ['$1'].
exprs -> expr exprs : ['$1' | '$2'].

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
assignment -> colon delimiters.

ident_or_keyword -> keyword : '$1'.
ident_or_keyword -> identifier : '$1'.

identifier_list -> ident_or_keyword delimiter : ['$1'].
identifier_list -> ident_or_keyword delimiter identifier_list : ['$1'|'$3'].

version_section -> version string delimiters : {version, '$2'}.

symbols_section -> new_symbols assignment identifier_list : {'$1', '$3'}.

Erlang code.
