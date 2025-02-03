open Query_plan_types
open Dataframe

let rec execute_select query_plan =
  match query_plan with
  | IndexScan (x, y, z) -> Actions.index_scan x y z
  | CrossJoin (l, r) ->
      let l_val = execute_select l in
      let r_val = execute_select r in
      Actions.cross_join l_val r_val
  | StdJoin (l, r, vars) ->
      let l_val = execute_select l in
      let r_val = execute_select r in
      Actions.std_join l_val r_val vars
  | SelectCols (r, vars) ->
      let v = execute_select r in
      Actions.select_cols vars v
  | Limit (r, n) ->
      let v = execute_select r in
      Actions.limit n v
  | _ -> failwith "modifying not permitted in select"

let execute_update query_plan =
  match query_plan with
  | Clear -> ()
  | InsertData data -> ()
  | DeleteData data -> ()
  | _ -> failwith "selecting not permitted in update"

let execute query_plan =
  match query_plan with
  | IndexScan _ | CrossJoin _ | StdJoin _ | SelectCols _ | Limit _ ->
      execute_select query_plan
  | Clear | InsertData _ | DeleteData _ -> execute_update query_plan
