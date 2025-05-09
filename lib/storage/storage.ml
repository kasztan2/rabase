open Types.Page_types

module HTBL = Hashtbl.MakeSeeded (struct
  type t = Stdint.uint32

  let seeded_hash _ u = Stdint.Uint32.to_int u
  let equal x y = Stdint.Uint32.compare x y == 0
end)

let pages : page HTBL.t = HTBL.create 100
let u32_of_int = Stdint.Uint32.of_int

let init () =
  HTBL.add pages (u32_of_int 0)
    (Page_header
       {
         page_count = u32_of_int 9;
         free_page_count = u32_of_int 0;
         autoincrement_id = Stdint.Uint64.zero;
         list_of_indexes =
           List.map (fun x -> u32_of_int x) [ 1; 2; 3; 4; 5; 6; 7; 8 ];
       });

  List.iter
    (fun i ->
      HTBL.add pages
        (u32_of_int (i + 1))
        (Page_data
           {
             index_type = i;
             child_page_numbers = [];
             sibling_page_number = None;
             triples = [];
           }))
    [ 0; 1; 2; 3; 4; 5 ];

  HTBL.add pages (u32_of_int 7)
    (Page_translation { is_from_id = true; child_page_numbers = []; items = [] });

  HTBL.add pages (u32_of_int 8)
    (Page_translation
       { is_from_id = false; child_page_numbers = []; items = [] })
;;

init ()

let change_root index_type new_root_page_num =
  match HTBL.find pages (u32_of_int 0) with
  | Page_header
      { page_count; free_page_count; autoincrement_id; list_of_indexes } ->
      HTBL.replace pages (u32_of_int 0)
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

let get_root index_type =
  match HTBL.find pages (u32_of_int 0) with
  | Page_header { list_of_indexes; _ } -> List.nth list_of_indexes index_type
  | _ -> failwith "not a header page at index 0"

let page_autoincrement () =
  match HTBL.find pages (u32_of_int 0) with
  | Page_header
      { page_count; free_page_count; autoincrement_id; list_of_indexes } ->
      HTBL.replace pages (u32_of_int 0)
        (Page_header
           {
             page_count = Stdint.Uint32.succ page_count;
             free_page_count;
             autoincrement_id;
             list_of_indexes;
           })
  | _ -> failwith "not a header page at index 0"

let get_translation_page page_num =
  let res = HTBL.find pages page_num in
  match res with
  | Page_translation p -> p
  | _ -> failwith "not a translation page"

let update_translation_page page_num new_page =
  HTBL.replace pages page_num (Page_translation new_page)

let update_data_page page_num new_page =
  HTBL.replace pages page_num (Page_data new_page)

let add_translation_page new_page =
  let page_num = Stdint.Uint32.of_int (HTBL.length pages) in
  HTBL.add pages page_num (Page_translation new_page);
  page_autoincrement ();
  page_num

let add_data_page new_page =
  let page_num = Stdint.Uint32.of_int (HTBL.length pages) in
  HTBL.add pages page_num (Page_data new_page);
  page_autoincrement ();
  page_num

let add_root_translation_from_id_page new_page =
  let page_num = add_translation_page new_page in
  change_root 6 page_num

let add_root_translation_from_value_page new_page =
  let page_num = add_translation_page new_page in
  change_root 7 page_num

let get_root_translation_from_id () = get_root 6
let get_root_translation_from_value () = get_root 7

let get_data_page page_num =
  let res = HTBL.find pages page_num in
  match res with Page_data p -> p | _ -> failwith "not a data page"

let clear_all () =
  HTBL.clear pages;
  init ()

let get_translation_id () =
  match HTBL.find pages (u32_of_int 0) with
  | Page_header
      { page_count; free_page_count; autoincrement_id; list_of_indexes } ->
      HTBL.replace pages (u32_of_int 0)
        (Page_header
           {
             page_count;
             free_page_count;
             autoincrement_id = Stdint.Uint64.succ autoincrement_id;
             list_of_indexes;
           });
      autoincrement_id
  | _ -> failwith "not a header page at index 0"

let debug () =
  HTBL.to_seq pages |> List.of_seq
  |> List.sort (fun (i1, _) (i2, _) -> Stdint.Uint32.compare i1 i2)
  |> List.map (fun (i, p) ->
         Format.asprintf "%d: %s" (Stdint.Uint32.to_int i)
           (Types.Page_types.show_page p))
  |> String.concat "\n"
