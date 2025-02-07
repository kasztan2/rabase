open Pages.Page_handler

module type S = sig
  type key_type
  type val_type
  type page_type

  val find : key_type -> val_type option
  val insert : key_type -> val_type -> unit
  val conv_basic_to_key : Types.Basic.basic_types -> key_type
  val conv_uint64_to_key : Stdint.uint64 -> key_type
  val conv_key_to_basic : key_type -> Types.Basic.basic_types
  val conv_key_to_uint64 : key_type -> Stdint.uint64
  val conv_uint64_to_val : Stdint.uint64 -> val_type
  val conv_basic_to_val : Types.Basic.basic_types -> val_type
  val conv_val_to_uint64 : val_type -> Stdint.uint64
  val conv_val_to_basic : val_type -> Types.Basic.basic_types
end

module Make (P : TranslationPageHandler) = struct
  type key_type = P.key_type
  type val_type = P.val_type
  type page_type = P.page_type

  let rec find_helper node x =
    match P.mem node x with
    | true -> P.get_val node x
    | false -> (
        match P.get_child node x with None -> None | Some c -> find_helper c x)

  let find x = find_helper (P.get_root ()) x

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
  let insert k v =
    let node = P.get_root () in
    match insert_helper node k v with
    | None -> ()
    | Some x -> P.create_new_root x

  let conv_basic_to_key x = P.conv_basic_to_key x
  let conv_uint64_to_key x = P.conv_uint64_to_key x
  let conv_key_to_basic x = P.conv_key_to_basic x
  let conv_key_to_uint64 x = P.conv_key_to_uint64 x
  let conv_uint64_to_val x = P.conv_uint64_to_val x
  let conv_basic_to_val x = P.conv_basic_to_val x
  let conv_val_to_uint64 x = P.conv_val_to_uint64 x
  let conv_val_to_basic x = P.conv_val_to_basic x
end
