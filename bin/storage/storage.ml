open Types.Page_types

let pages : (Stdint.uint32, page) Hashtbl.t = Hashtbl.create 100
let u32_of_int = Stdint.Uint32.of_int;;

Hashtbl.add pages (u32_of_int 0)
  (Page_header
     {
       page_count = u32_of_int 9;
       free_page_count = u32_of_int 0;
       autoincrement_id = Stdint.Uint64.zero;
       list_of_indexes =
         List.map (fun x -> u32_of_int x) [ 1; 2; 3; 4; 5; 6; 7; 8 ];
     })
;;

List.iter
  (fun i ->
    Hashtbl.add pages
      (u32_of_int (i + 1))
      (Page_data_leaf
         {
           index_type = Stdint.Uint8.of_int i;
           sibling_page_number = u32_of_int 0;
           triples = [];
         }))
  [ 0; 1; 2; 3; 4; 5 ]
;;

Hashtbl.add pages (u32_of_int 7)
  (Page_translation { is_from_id = true; child_page_numbers = []; items = [] })
;;

Hashtbl.add pages (u32_of_int 8)
  (Page_translation { is_from_id = false; child_page_numbers = []; items = [] })

let change_root index_type new_root_page_num =
  match Hashtbl.find pages (u32_of_int 0) with
  | Page_header
      { page_count; free_page_count; autoincrement_id; list_of_indexes } ->
      Hashtbl.replace pages (u32_of_int 0)
        (Page_header
           {
             page_count;
             free_page_count;
             autoincrement_id;
             list_of_indexes =
               List.mapi
                 (fun i x -> if i == index_type then new_root_page_num else x)
                 list_of_indexes;
           })
  | _ -> failwith "not a header page at index 0"

let page_autoincrement () =
  match Hashtbl.find pages (u32_of_int 0) with
  | Page_header
      { page_count; free_page_count; autoincrement_id; list_of_indexes } ->
      Hashtbl.replace pages (u32_of_int 0)
        (Page_header
           {
             page_count = Stdint.Uint32.succ page_count;
             free_page_count;
             autoincrement_id;
             list_of_indexes;
           })
  | _ -> failwith "not a header page at index 0"

let get_translation_page page_num =
  let res = Hashtbl.find pages page_num in
  match res with
  | Types.Page_types.Page_translation p -> p
  | _ -> failwith "not a translation page"

let update_translation_page page_num new_page =
  Hashtbl.replace pages page_num (Page_translation new_page)

let add_translation_page new_page =
  let page_num = Stdint.Uint32.of_int (Hashtbl.length pages) in
  Hashtbl.add pages page_num (Page_translation new_page);
  page_autoincrement ();
  page_num

let add_root_translation_from_id_page new_page =
  let page_num = add_translation_page new_page in
  change_root 6 page_num

let add_root_translation_from_value_page new_page =
  let page_num = add_translation_page new_page in
  change_root 7 page_num
