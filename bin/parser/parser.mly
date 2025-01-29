%{
  open Sparql_ast
%}
%token SELECT
%token DISTINCT
%token WHERE
%token LIMIT
%token INSERT DELETE DATA
%token CLEAR

%token LBRACE RBRACE
%token STAR DOT

%token <string> IRIREF
%token <string> VAR
%token <int> INTEGER

%token EOF

%start <Sparql_ast.query> query
%start <Sparql_ast.update> update

%%

let query :=
  | q=select_query; EOF; { Query q }

let select_query :=
  | c=select_clause; w=where_clause; {SelectQuery(c, w, None)}
  | c=select_clause; w=where_clause; m=solution_modifier; { SelectQuery(c, w, Some m) }

let select_clause :=
  | SELECT; DISTINCT?; v=vars_or_all; { SelectClause v }

let vars_or_all :=
  | STAR; {All}
  | v=var+; {Vars v}

let where_clause :=
  | WHERE?; g=graph_group_pattern; {WhereClause g}

let graph_group_pattern :=
  | LBRACE; p=graph_pattern+; RBRACE; {GroupPatterns p}

let graph_pattern :=
  | p=triple_graph_pattern; DOT; {p}

let triple_graph_pattern :=
  | v1=var_or_term; v2=var_or_term; v3=var_or_term; {TripleGraphPattern(v1, v2, v3)}

let var_or_term :=
  | var
  | term

let var :=
  | v=VAR; {Var v}

let term :=
  | i=IRIREF; {Iri i}

let solution_modifier :=
  | LIMIT; v=INTEGER; {Limit v}

let update :=
  | h=update_helper; EOF; {Update h}

let update_helper :=
  | INSERT; DATA; g=graph_group_pattern_no_vars; {InsertData g}
  | DELETE; DATA; g=graph_group_pattern_no_vars; {DeleteData g}
  | CLEAR; {Clear}

let graph_group_pattern_no_vars :=
  | LBRACE; p=graph_pattern_no_vars+; RBRACE; {GroupPatterns p}

let graph_pattern_no_vars :=
  | p=triple_graph_pattern_no_vars; DOT; {p}

let triple_graph_pattern_no_vars :=
  | t1=term; t2=term; t3=term; {TripleGraphPattern(t1, t2, t3)}

