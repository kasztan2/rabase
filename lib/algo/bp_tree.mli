module type S = sig
  val find :
    Stdint.uint64 option * Stdint.uint64 option * Stdint.uint64 option ->
    Types.Page_types.triple list

  val insert : Types.Page_types.triple -> unit
end

module Make (_ : Pages.Page_handler.DataPageHandler) : S
