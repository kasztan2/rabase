module type S = sig
  type key_type
  type val_type
  type page_type

  val find : key_type -> val_type option
  val insert : key_type -> val_type -> unit
  val conv_to_key_type : Types.Basic.basic_types -> key_type
  val conv_from_val_type : val_type -> Stdint.uint64
end

module Make (_ : Pages.Page_handler.PageHandler) : S
