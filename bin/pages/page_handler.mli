module type TranslationPageHandler = sig
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

module type DataPageHandler = sig
  type page_type

  val get_root : unit -> page_type

  val get_vals :
    page_type ->
    Stdint.uint64 option * Stdint.uint64 option * Stdint.uint64 option ->
    Types.Page_types.triple list

  val get_child :
    page_type ->
    Stdint.uint64 option * Stdint.uint64 option * Stdint.uint64 option ->
    page_type option

  val is_leaf : page_type -> bool

  val insert :
    page_type ->
    ?two_children:page_type * page_type ->
    Types.Page_types.triple ->
    unit

  val one_triple_fits : page_type -> bool

  val split :
    page_type ->
    Types.Page_types.triple ->
    page_type * Types.Page_types.triple * page_type

  val create_new_root : page_type * Types.Page_types.triple * page_type -> unit
end
