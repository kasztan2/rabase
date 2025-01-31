type triple = Stdint.uint64 * Stdint.uint64 * Stdint.uint64
type index_type = Stdint.uint16
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

type 'a translation_interior_page = {
  index_type : index_type;
  child_page_numbers : page_num list;
  keys : 'a list;
}

type ('a, 'b) translation_leaf_page = {
  index_type : index_type;
  sibling_page_number : page_num;
  items : ('a * 'b) list;
}

type _ page =
  | Page_data_interior : data_interior_page -> data_interior_page page
  | Page_data_leaf : data_leaf_page -> data_leaf_page page
  | Page_translation_interior :
      'a translation_interior_page
      -> 'a translation_interior_page page
  | Page_translation_leaf :
      ('a, 'b) translation_leaf_page
      -> ('a, 'b) translation_leaf_page page
