module type PageHandler = sig
  type key_type
  type val_type
  type page_type

  val mem : page_type -> key_type -> bool
  val get_val : page_type -> key_type -> val_type option
  val get_child : page_type -> key_type -> page_type option
  val is_leaf : page_type -> bool
  val insert : page_type -> key_type -> val_type -> unit
end
