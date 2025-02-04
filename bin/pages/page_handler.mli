module type PageHandler = sig
  type key_type
  type val_type
  type page_type

  val conv_to_key_type : Types.Basic.basic_types -> key_type
  val conv_from_val_type : val_type -> Stdint.uint64
  val get_root : unit -> page_type
  val mem : page_type -> key_type -> bool
  val get_val : page_type -> key_type -> val_type option
  val get_child : page_type -> key_type -> page_type option
  val is_leaf : page_type -> bool

  val insert :
    page_type ->
    ?two_children:page_type * page_type ->
    key_type ->
    val_type ->
    unit

  val fits : page_type -> key_type -> val_type -> bool

  val split :
    page_type ->
    key_type ->
    val_type ->
    page_type * (key_type * val_type) * page_type

  val create_new_root : page_type * (key_type * val_type) * page_type -> unit
end
