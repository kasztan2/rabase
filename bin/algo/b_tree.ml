open Pages.Page_handler

module type S = sig
  type key_type
  type val_type
  type page_type

  val find : page_type -> key_type -> val_type option
  val insert : page_type -> key_type -> val_type -> unit
end

module B_tree (P : PageHandler) : S = struct
  type key_type = P.key_type
  type val_type = P.val_type
  type page_type = P.page_type

  let rec find node x =
    match P.mem node x with
    | true -> P.get_val node x
    | false -> (
        match P.get_child node x with None -> None | Some c -> find c x)

  let check_and_split node ?two_children k v =
    match P.fits node k v with
    | false -> Some (P.split node k v)
    | true ->
        P.insert node ?two_children k v;
        None

  let rec insert_helper node k v =
    match P.is_leaf node with
    | false -> (
        match P.get_child node k with
        | None -> failwith "what"
        | Some c -> (
            match insert_helper c k v with
            | None -> None
            | Some (p1, (k, v), p2) ->
                check_and_split node ?two_children:(Some (p1, p2)) k v))
    | true -> check_and_split node k v

  (** assumes that there is no such element present already *)
  let insert node k v =
    match insert_helper node k v with
    | None -> ()
    | Some x -> P.create_new_root x
end
