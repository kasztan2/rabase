type var_or_object = Var of string | Object of string [@@deriving show]

type concrete_data = (var_or_object * var_or_object * var_or_object) list
[@@deriving show]

type query_plan =
  | IndexScan of var_or_object * var_or_object * var_or_object
  | CrossJoin of query_plan * query_plan
  | StdJoin of query_plan * query_plan * var_or_object list
  | SelectCols of query_plan * var_or_object list
  | Limit of query_plan * int
  | Clear
  | InsertData of concrete_data
  | DeleteData of concrete_data
[@@deriving show]
