type var_or_object = Var of string | Object of string

val pp_var_or_object : Format.formatter -> var_or_object -> unit
val show_var_or_object : var_or_object -> string

type concrete_data = (var_or_object * var_or_object * var_or_object) list

val pp_concrete_data : Format.formatter -> concrete_data -> unit
val show_concrete_data : concrete_data -> string

type query_plan =
  | IndexScan of var_or_object * var_or_object * var_or_object
  | CrossJoin of query_plan * query_plan
  | StdJoin of query_plan * query_plan * var_or_object list
  | SelectCols of query_plan * var_or_object list
  | Limit of query_plan * int
  | Clear
  | InsertData of concrete_data
  | DeleteData of concrete_data

val pp_query_plan : Format.formatter -> query_plan -> unit
val show_query_plan : query_plan -> string
