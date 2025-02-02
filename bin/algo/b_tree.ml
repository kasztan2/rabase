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

  (** assumes that there is no such element present already *)
  let rec insert node x y =
    match P.is_leaf node with
    | false -> (
        match P.get_child node x with
        | Some c -> insert c x y
        | None -> failwith "what")
    | true -> P.insert node x y
end
