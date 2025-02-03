type triple = Stdint.uint64 * Stdint.uint64 * Stdint.uint64
type index_type = Stdint.uint8
type page_num = Stdint.uint32

type header_page = {
  page_count : Stdint.uint32;
  free_page_count : Stdint.uint32;
  autoincrement_id : Stdint.uint64;
  list_of_indexes : page_num list;
}

type data_interior_page = {
  index_type : index_type;
  child_page_numbers : page_num list;
  triples : triple list;
}

type data_leaf_page = {
  index_type : index_type;
  sibling_page_number : page_num;
  triples : triple list;
}

type translation_page = {
  is_from_id : bool;
  child_page_numbers : page_num list;
  items : (Stdint.uint64 * Basic.basic_types) list;
}

type page =
  | Page_data_interior of data_interior_page
  | Page_data_leaf of data_leaf_page
  | Page_translation of translation_page
  | Page_header of header_page
