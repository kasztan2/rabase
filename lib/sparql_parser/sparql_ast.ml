type query =
  | Query of query
  | SelectQuery of query * query * query option
  | SelectClause of query
  | WhereClause of query
  | GroupPatterns of query list
  | TripleGraphPattern of query * query * query
  | Var of string
  | Iri of string
  | Integer of int64
  | String of string
  | Limit of int64
  | Update of query
  | InsertData of query
  | DeleteData of query
  | Clear
  | All
  | Vars of query list

type update = query
