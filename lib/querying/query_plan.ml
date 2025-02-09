open Sparql_parser
module AST = Sparql_ast
open Query_plan_types

let conv_var v_ast =
  match v_ast with AST.Var x -> Var x | _ -> failwith "not a variable"

let conv_iri iri =
  match iri with AST.Iri x -> Object x | _ -> failwith "not an object"

let conv_integer i =
  match i with
  | AST.Integer x -> Literal (Types.Basic.T_Int64 x)
  | _ -> failwith "not a 64-bit integer"

let conv_var_or_object ast =
  match ast with
  | AST.Var _ -> conv_var ast
  | AST.Iri _ -> conv_iri ast
  | AST.Integer _ -> conv_integer ast
  | _ -> failwith "neither var nor object"

let conv_concrete a =
  match a with
  | AST.Iri x -> Literal (Types.Basic.T_Iri x)
  | AST.Integer _ -> conv_integer a
  | _ -> failwith "not concrete"

let conv_vars vs_ast =
  match vs_ast with
  | AST.Vars vars ->
      List.map
        (fun var ->
          match var with
          | AST.Var x -> Var x
          | _ -> failwith "not a variable inside AST.Vars")
        vars
  | _ -> failwith "not a list of variables"

module StringSet = Set.Make (String)

let get_triple_vars_strings triple =
  match triple with
  | AST.TripleGraphPattern (v1, v2, v3) ->
      let l = [ v1; v2; v3 ] in
      List.filter_map
        (function
          | AST.Iri _ -> None
          | AST.Var x -> Some x
          | AST.Integer _ -> None
          | _ -> failwith "not a var or iri")
        l
      |> StringSet.of_list
  | _ -> failwith "not a triple pattern"

let make_index_scan triple_pattern =
  match triple_pattern with
  | AST.TripleGraphPattern (v1, v2, v3) ->
      let v1 = conv_var_or_object v1 in
      let v2 = conv_var_or_object v2 in
      let v3 = conv_var_or_object v3 in
      IndexScan (v1, v2, v3)
  | _ -> failwith "not a triple pattern"

let rec make_query_plan_select ast =
  match ast with
  | AST.SelectQuery (s, w, m) -> (
      match m with
      | Some x -> (
          match x with
          | AST.Limit x ->
              Limit (make_query_plan_select (AST.SelectQuery (s, w, None)), x)
          | _ -> failwith "not permitted")
      | None -> (
          match s with
          | AST.SelectClause s ->
              SelectCols (make_query_plan_select w, conv_vars s)
          | _ -> failwith "not a select clause"))
  | AST.WhereClause w -> (
      match w with
      | AST.GroupPatterns _ -> make_query_plan_select w
      | _ -> failwith "not a group pattern")
  | AST.GroupPatterns g ->
      let _, query_plan =
        List.fold_left
          (fun (known_vars, tree) triple ->
            let leaf = make_index_scan triple in
            let cur_vars = get_triple_vars_strings triple in
            let common_vars = StringSet.inter known_vars cur_vars in
            let new_known_vars = StringSet.union cur_vars known_vars in
            match StringSet.cardinal common_vars with
            | 0 -> (new_known_vars, CrossJoin (tree, leaf))
            | _ ->
                ( new_known_vars,
                  StdJoin
                    ( tree,
                      leaf,
                      List.map (fun x -> Var x) (StringSet.to_list common_vars)
                    ) ))
          (get_triple_vars_strings (List.hd g), make_index_scan (List.hd g))
          (List.tl g)
      in
      query_plan
  | AST.All -> failwith "not yet supported"
  | _ -> failwith "AST structure incorrect"

let conv_data ast =
  match ast with
  | AST.GroupPatterns ps ->
      List.map
        (function
          | AST.TripleGraphPattern (t1, t2, t3) ->
              let t1 = conv_concrete t1 in
              let t2 = conv_concrete t2 in
              let t3 = conv_concrete t3 in
              (t1, t2, t3)
          | _ -> failwith "not a triple pattern")
        ps
  | _ -> failwith "not group patterns"

let make_query_plan_update ast =
  match ast with
  | AST.InsertData g -> InsertData (conv_data g)
  | AST.DeleteData g -> DeleteData (conv_data g)
  | AST.Clear -> Clear
  | _ -> failwith "not an update operation"

let make_query_plan ast =
  match ast with
  | AST.Query q -> make_query_plan_select q
  | AST.Update u -> make_query_plan_update u
  | _ -> failwith "AST structure incorrect"
