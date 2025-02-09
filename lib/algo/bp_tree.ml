open Pages.Page_handler

module type S = sig
  val find :
    Stdint.uint64 option * Stdint.uint64 option * Stdint.uint64 option ->
    Types.Page_types.triple list

  val insert : Types.Page_types.triple -> unit
end

module Make (P : DataPageHandler) = struct
  let rec find_helper node x =
    match P.is_leaf node with
    | true -> P.get_vals node x
    | false -> (
        match P.get_child node x with None -> [] | Some c -> find_helper c x)

  let find x = find_helper (P.get_root ()) x

  let check_and_split node ?two_children tr =
    match P.one_triple_fits node with
    | false -> Some (P.split node tr)
    | true ->
        P.insert node ?two_children tr;
        None

  let tr_to_opt_tr (x, y, z) = (Some x, Some y, Some z)

  let rec insert_helper node (tr : Types.Page_types.triple) =
    match P.is_leaf node with
    | false -> (
        match P.get_child node (tr_to_opt_tr tr) with
        | None -> failwith "what"
        | Some c -> (
            match insert_helper c tr with
            | None -> None
            | Some (p1, tr, p2) ->
                check_and_split node ?two_children:(Some (p1, p2)) tr))
    | true -> check_and_split node tr

  let insert (tr : Types.Page_types.triple) =
    let node = P.get_root () in
    match insert_helper node tr with
    | None -> ()
    | Some x -> P.create_new_root x
end
