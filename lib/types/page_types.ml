module Stdint = struct
  include Stdint

  let pp_uint64 fmt u = Format.fprintf fmt "%s" (Uint64.to_string u)
  let pp_uint32 fmt u = Format.fprintf fmt "%s" (Uint32.to_string u)
end

type triple = Stdint.uint64 * Stdint.uint64 * Stdint.uint64 [@@deriving show]
type page_num = Stdint.uint32 [@@deriving show]

type header_page = {
  page_count : Stdint.uint32;
  free_page_count : Stdint.uint32;
  autoincrement_id : Stdint.uint64;
  list_of_indexes : page_num list;
}
[@@deriving show]

type data_page = {
  index_type : int;
  child_page_numbers : page_num list;
  sibling_page_number : page_num option;
  triples : triple list;
}
[@@deriving show]

type translation_page = {
  is_from_id : bool;
  child_page_numbers : page_num list;
  items : (Stdint.uint64 * Basic.basic_types) list;
}
[@@deriving show]

type page =
  | Page_data of data_page
  | Page_translation of translation_page
  | Page_header of header_page
[@@deriving show]
