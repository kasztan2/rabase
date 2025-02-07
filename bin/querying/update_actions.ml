open Query_plan_types
open Trees
module S = Storage

let ensure_concrete l =
  List.iter
    (function
      | Var _, _, _ | _, Var _, _ | _, _, Var _ -> failwith "data not concrete"
      | _ -> ())
    l

let clear () = S.clear_all ()

let transform_to_id v =
  match v with
  | Object _ -> failwith "why did I introduce this type?"
  | Literal x -> (
      match BTree_from_value.find (BTree_from_value.conv_basic_to_key x) with
      | None ->
          let id = S.get_translation_id () in
          BTree_from_id.insert
            (BTree_from_id.conv_uint64_to_key id)
            (BTree_from_id.conv_basic_to_val x);
          BTree_from_value.insert
            (BTree_from_value.conv_basic_to_key x)
            (BTree_from_value.conv_uint64_to_val id);
          id
      | Some r -> BTree_from_value.conv_val_to_uint64 r)
  | _ -> failwith "cannot be transformed to id"

let insert_data data =
  ensure_concrete data;
  let rows =
    List.map
      (fun (a, b, c) ->
        (transform_to_id a, transform_to_id b, transform_to_id c))
      data
  in
  List.iter
    (fun row ->
      List.iter
        (fun f -> f row)
        [
          BPTree_SPO.insert;
          BPTree_SOP.insert;
          BPTree_PSO.insert;
          BPTree_POS.insert;
          BPTree_OSP.insert;
          BPTree_OPS.insert;
        ])
    rows
