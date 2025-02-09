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

module Make (_ : Pages.Page_handler.TranslationPageHandler) : S
