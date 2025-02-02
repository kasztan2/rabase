open Dataframe
open Query_plan_types

let vars_to_strings vars =
  List.map (function Var x -> x | _ -> failwith "not a var") vars

let limit n { var_names; rows } =
  { var_names; rows = List.drop (List.length rows - n) rows }

let add_indexes l = List.mapi (fun i x -> (i, x)) l
let only_indexes l = List.map (fun (i, _x) -> i) l

let select_cols vars { var_names; rows } =
  let vars = vars_to_strings vars in
  let indexes =
    add_indexes var_names
    |> List.filter (fun (_i, x) -> List.mem x vars)
    |> only_indexes
  in
  let row_transform =
   fun r ->
    add_indexes r
    |> List.filter (fun (i, _x) -> List.mem i indexes)
    |> List.map (fun (_i, x) -> x)
  in
  { var_names = vars; rows = List.map row_transform rows }

let cross_combine l1 l2 =
  List.concat_map (fun x -> List.map (fun y -> (x, y)) l2) l1

let cross_join { var_names = var_names1; rows = rows1 }
    { var_names = var_names2; rows = rows2 } =
  let new_var_names = List.append var_names1 var_names2 in
  let new_rows =
    cross_combine rows1 rows2 |> List.map (fun (x, y) -> List.append x y)
  in
  { var_names = new_var_names; rows = new_rows }

let std_join df1 df2 vars =
  let vars = vars_to_strings vars in
  let { var_names = crossed_vars; rows = crossed_rows } = cross_join df1 df2 in
  let crossed_vars_with_indexes = add_indexes crossed_vars in
  let find_indexes =
   fun x ->
    List.find_all (fun (_i, y) -> y == x) crossed_vars_with_indexes
    |> List.map (fun (i, _v) -> i)
  in
  let index_pairs =
    List.map
      (fun v ->
        let res = find_indexes v in
        match List.length res with
        | 2 -> res
        | _ -> failwith "wrong output of crossed join")
      vars
    |> List.map (function [ x; y ] -> (x, y) | _ -> failwith "what")
  in
  let is_row_ok =
   fun r ->
    List.map (fun (x, y) -> List.nth r x == List.nth r y) index_pairs
    |> List.for_all (fun b -> b)
  in
  let indexes_to_delete = List.map (fun (_a, b) -> b) index_pairs in
  let remove_duplicates =
   fun l -> List.filteri (fun i _x -> List.mem i indexes_to_delete) l
  in
  let new_rows =
    List.filter is_row_ok crossed_rows |> List.map remove_duplicates
  in
  let new_vars = remove_duplicates crossed_vars in
  { var_names = new_vars; rows = new_rows }
