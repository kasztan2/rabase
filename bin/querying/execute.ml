open Query_plan

let execute_select query_plan =
  match query_plan with
  | IndexScan (x, y, z) -> ()
  | CrossJoin (l, r) -> ()
  | StdJoin (l, r, vars) -> ()
  | SelectCols (r, vars) -> ()
  | Limit (r, n) -> ()
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
