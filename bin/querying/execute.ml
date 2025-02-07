open Query_plan_types
open Dataframe

let rec execute_select query_plan =
  match query_plan with
  | IndexScan (x, y, z) -> Select_actions.index_scan x y z
  | CrossJoin (l, r) ->
      let l_val = execute_select l in
      let r_val = execute_select r in
      Select_actions.cross_join l_val r_val
  | StdJoin (l, r, vars) ->
      let l_val = execute_select l in
      let r_val = execute_select r in
      Select_actions.std_join l_val r_val vars
  | SelectCols (r, vars) ->
      let v = execute_select r in
      Select_actions.select_cols vars v
  | Limit (r, n) ->
      let v = execute_select r in
      Select_actions.limit n v
  | _ -> failwith "modifying not permitted in select"

let empty_df = { var_names = []; rows = [] }

let execute_update query_plan =
  match query_plan with
  | Clear ->
      Update_actions.clear ();
      empty_df
  | InsertData data ->
      Update_actions.insert_data data;
      empty_df
  | DeleteData data ->
      (*TODO implement*)
      ignore data;
      empty_df
  | _ -> failwith "selecting not permitted in update"

let execute query_plan =
  (match query_plan with
  | IndexScan _ | CrossJoin _ | StdJoin _ | SelectCols _ | Limit _ ->
      execute_select query_plan
  | Clear | InsertData _ | DeleteData _ -> execute_update query_plan)
  |> Select_actions.df_to_values
