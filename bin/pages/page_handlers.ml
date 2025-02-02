open Page_handler
module S = Storage

module TranslationFromID : PageHandler = struct
  type key_type = Stdint.uint64
  type val_type = Types.Basic.basic_types
  type page_type = Stdint.uint64 (*Types.Page_types.translation_page*)

  let mem (page : page_type) key =
    List.exists (fun (id, _val) -> id == key) page.items

  let get_val (page : page_type) key =
    let _, v = List.find (fun (id, _val) -> id == key) page.items in
    Some v

  let get_child (page : page_type) key =
    let ind =
      match List.find_index (fun (id, _val) -> id > key) page.items with
      | Some x -> x
      | None -> List.length page.items
    in
    let child_page_num = List.nth page.child_page_numbers ind in
    S.get child_page_num

  let is_leaf (page : page_type) = List.length page.child_page_numbers == 0
  let insert page key value = ()
  (* let added = (key, value)::page.items *)
end
