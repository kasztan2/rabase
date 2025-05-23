open Dataframe
open Query_plan_types
open Trees

type id_or_var = Id of Stdint.uint64 | VarName of string

let into_basic_type x =
  match x with
  | Var _ -> failwith "cannot convert a var into basic type"
  | Object x -> Types.Basic.T_Iri x |> BTree_from_value.conv_basic_to_key
  | Literal x -> BTree_from_value.conv_basic_to_key x

let into_var_or_id x =
  match x with
  | Var s -> VarName s
  | x -> (
      let x : BTree_from_value.key_type = into_basic_type x in
      let id : BTree_from_value.val_type option = BTree_from_value.find x in
      match id with
      | None -> failwith "a literal wasn't found"
      | Some x -> Id (BTree_from_value.conv_val_to_uint64 x))

let into_df fields rows =
  let indexes =
    List.mapi (fun i x -> (i, x)) fields
    |> List.filter_map (function i, VarName _ -> Some i | _ -> None)
  in
  let vars =
    List.filter_map (function VarName x -> Some x | _ -> None) fields
  in
  let new_rows =
    List.map
      (fun (x, y, z) ->
        let row = [ x; y; z ] in
        List.filteri (fun i _ -> List.mem i indexes) row)
      rows
  in
  { var_names = vars; rows = new_rows }

let index_scan x y z =
  let x = into_var_or_id x in
  let y = into_var_or_id y in
  let z = into_var_or_id z in
  (*TODO continue writing*)
  let res =
    match (x, y, z) with
    | Id x, VarName _, VarName _ -> BPTree_SPO.find (Some x, None, None)
    | Id x, Id y, VarName _ -> BPTree_SPO.find (Some x, Some y, None)
    | Id x, VarName _, Id z -> BPTree_SOP.find (Some x, None, Some z)
    | VarName _, VarName _, Id z -> BPTree_OPS.find (None, None, Some z)
    | VarName _, Id y, VarName _ -> BPTree_PSO.find (None, Some y, None)
    | VarName _, Id y, Id z -> BPTree_PSO.find (None, Some y, Some z)
    | VarName _, VarName _, VarName _ -> BPTree_SPO.find (None, None, None)
    | _ -> []
  in
  into_df [ x; y; z ] res

let vars_to_strings vars =
  List.map (function Var x -> x | _ -> failwith "not a var") vars

let limit n { var_names; rows } =
  let n = Int64.to_int n in
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
  if List.length indexes < List.length vars then
    failwith "some variable was not found";
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
  Logs.debug (fun m -> m "std_join on vars: %s" (String.concat "," vars));
  let { var_names = crossed_vars; rows = crossed_rows } = cross_join df1 df2 in
  Logs.debug (fun m -> m "cross_join vars: %s" (String.concat "," crossed_vars));
  let crossed_vars_with_indexes = add_indexes crossed_vars in
  let find_indexes =
   fun x ->
    List.find_all (fun (_i, y) -> y = x) crossed_vars_with_indexes
    |> List.map (fun (i, _v) -> i)
  in
  let index_pairs =
    List.map
      (fun v ->
        let res = find_indexes v in
        Logs.debug (fun m ->
            m "find_indexes of %s produced %d results: %s" v (List.length res)
              (String.concat "," (List.map string_of_int res)));
        match List.length res with
        | 2 -> res
        | _ -> failwith "wrong output of crossed join")
      vars
    |> List.map (function [ x; y ] -> (x, y) | _ -> failwith "what")
  in
  let is_row_ok =
   fun r ->
    List.map (fun (x, y) -> List.nth r x = List.nth r y) index_pairs
    |> List.for_all (fun b -> b)
  in
  let indexes_to_delete = List.map (fun (_a, b) -> b) index_pairs in
  Logs.debug (fun m ->
      m "indexes_to_delete: %s"
        (String.concat "," (List.map string_of_int indexes_to_delete)));
  let remove_duplicates =
   fun l -> List.filteri (fun i _x -> Bool.not (List.mem i indexes_to_delete)) l
  in
  let new_rows =
    List.filter is_row_ok crossed_rows |> List.map remove_duplicates
  in
  let new_vars = remove_duplicates crossed_vars in
  let output = { var_names = new_vars; rows = new_rows } in
  Logs.debug (fun m -> m "std_join output: %s" (show_dataframe output));
  output

let back_into_value x =
  match BTree_from_id.find (BTree_from_id.conv_uint64_to_key x) with
  | None -> failwith "cannot find a value with given id"
  | Some x -> BTree_from_id.conv_val_to_basic x

let df_to_values { var_names; rows } =
  let new_rows =
    List.map (fun row -> List.map (fun x -> back_into_value x) row) rows
  in
  (var_names, new_rows)
