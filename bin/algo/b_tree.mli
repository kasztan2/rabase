module type S = sig
  type key_type
  type val_type
  type page_type

  val find : page_type -> key_type -> val_type option
  val insert : page_type -> key_type -> val_type -> unit
end

module B_tree : (_ : Pages.Page_handler.PageHandler) -> S
