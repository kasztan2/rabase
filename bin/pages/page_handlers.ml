open Page_handler
open Types.Page_types
module S = Storage

module TranslationFromID : PageHandler = struct
  type key_type = Stdint.uint64
  type val_type = Types.Basic.basic_types

  type page_type = Stdint.uint32
  (** ok, so this type is kind of unnecessary now, but let's keep it just in
      case *)

  let mem (page : page_type) key =
    let page = S.get_translation_page page in
    List.exists (fun (id, _val) -> id == key) page.items

  let get_val (page : page_type) key =
    let page = S.get_translation_page page in
    let _, v = List.find (fun (id, _val) -> id == key) page.items in
    Some v

  let get_child (page : page_type) key =
    let page = S.get_translation_page page in
    let ind =
      match List.find_index (fun (id, _val) -> id > key) page.items with
      | Some x -> x
      | None -> List.length page.items
    in
    let child_page_num = List.nth page.child_page_numbers ind in
    (*TODO None if error?*)
    Some child_page_num

  let is_leaf (page : page_type) =
    let page = S.get_translation_page page in
    List.length page.child_page_numbers == 0

  let inserted page_num key value two_children =
    let page = S.get_translation_page page_num in
    let ind =
      match List.find_index (fun (k, _) -> k > key) page.items with
      | Some x -> x
      | None -> List.length page.items
    in
    let new_items = Utils.List.insert_at ind (key, value) page.items in
    let new_child_page_numbers =
      match two_children with
      | Some (l, r) -> (
          match List.length page.child_page_numbers with
          | 0 -> [ l; r ]
          | 1 -> failwith "shouldn't happen"
          | _ ->
              Utils.List.insert_at ind l page.child_page_numbers
              |> Utils.List.modify_at_pos (ind + 1) r)
      | None -> page.child_page_numbers
    in
    let new_page =
      {
        is_from_id = true;
        child_page_numbers = new_child_page_numbers;
        items = new_items;
      }
    in
    new_page

  let insert page_num ?two_children key value =
    let new_page = inserted page_num key value two_children in
    S.update_translation_page page_num new_page

  let calculate_item_size = fun (_k, v) -> 8 + 1 + Helpers.calculate_type_size v

  let calculate_items_size items =
    List.map calculate_item_size items
    |> List.fold_left (fun acc x -> acc + x) 0

  let calculate_page_size page =
    let overhead = 3 + (List.length page.items * 2) in
    let for_children = List.length page.child_page_numbers * 4 in
    let for_items = calculate_items_size page.items in
    overhead + for_children + for_items

  let fits page_num key value =
    let new_page = inserted page_num key value None in
    let size = calculate_page_size new_page in
    size <= 4096

  let split page_num key value =
    let new_page = inserted page_num key value None in
    let sizes = List.map calculate_item_size new_page.items in
    let cumulative_sizes =
      List.fold_left
        (fun acc x ->
          match acc with
          | f :: acc -> (x + f) :: f :: acc
          | _ -> failwith "impossible")
        [ 0 ] sizes
      |> List.rev |> List.tl
    in
    let total_items_size = calculate_items_size new_page.items in
    let mid_item_index =
      match
        List.find_index (fun x -> x > total_items_size / 2) cumulative_sizes
      with
      | None -> failwith "mid index cannot be found"
      | Some x -> x
    in
    let left_items, middle_item, right_items =
      Utils.List.split_with_middle mid_item_index new_page.items
    in
    let left_children, right_children =
      match List.is_empty new_page.child_page_numbers with
      | true -> ([], [])
      | false ->
          Utils.List.split (mid_item_index + 1) new_page.child_page_numbers
    in
    let left_page =
      {
        is_from_id = true;
        child_page_numbers = left_children;
        items = left_items;
      }
    in
    let right_page =
      {
        is_from_id = true;
        child_page_numbers = right_children;
        items = right_items;
      }
    in
    S.update_translation_page page_num left_page;
    let right_page_num = S.add_translation_page right_page in
    (page_num, middle_item, right_page_num)

  let create_new_root (p1, item, p2) =
    let new_page =
      { is_from_id = true; child_page_numbers = [ p1; p2 ]; items = [ item ] }
    in
    S.add_root_translation_from_id_page new_page
end

module TranslationFromValue : PageHandler = struct
  type key_type = Types.Basic.basic_types
  type val_type = Stdint.uint64

  type page_type = Stdint.uint32
  (** ok, so this type is kind of unnecessary now, but let's keep it just in
      case *)

  let mem (page : page_type) key =
    let page = S.get_translation_page page in
    List.exists (fun (_id, value) -> value == key) page.items

  let get_val (page : page_type) key =
    let page = S.get_translation_page page in
    let i, _ = List.find (fun (_id, value) -> value == key) page.items in
    Some i

  let get_child (page : page_type) key =
    let page = S.get_translation_page page in
    let ind =
      match List.find_index (fun (_id, value) -> value > key) page.items with
      | Some x -> x
      | None -> List.length page.items
    in
    let child_page_num = List.nth page.child_page_numbers ind in
    (*TODO None if error?*)
    Some child_page_num

  let is_leaf (page : page_type) =
    let page = S.get_translation_page page in
    List.length page.child_page_numbers == 0

  let inserted page_num key value two_children =
    let page = S.get_translation_page page_num in
    let ind =
      match List.find_index (fun (_, v) -> v > key) page.items with
      | Some x -> x
      | None -> List.length page.items
    in
    let new_items = Utils.List.insert_at ind (value, key) page.items in
    let new_child_page_numbers =
      match two_children with
      | Some (l, r) -> (
          match List.length page.child_page_numbers with
          | 0 -> [ l; r ]
          | 1 -> failwith "shouldn't happen"
          | _ ->
              Utils.List.insert_at ind l page.child_page_numbers
              |> Utils.List.modify_at_pos (ind + 1) r)
      | None -> page.child_page_numbers
    in
    let new_page =
      {
        is_from_id = true;
        child_page_numbers = new_child_page_numbers;
        items = new_items;
      }
    in
    new_page

  let insert page_num ?two_children key value =
    let new_page = inserted page_num key value two_children in
    S.update_translation_page page_num new_page

  let calculate_item_size = fun (_k, v) -> 8 + 1 + Helpers.calculate_type_size v

  let calculate_items_size items =
    List.map calculate_item_size items
    |> List.fold_left (fun acc x -> acc + x) 0

  let calculate_page_size page =
    let overhead = 3 + (List.length page.items * 2) in
    let for_children = List.length page.child_page_numbers * 4 in
    let for_items = calculate_items_size page.items in
    overhead + for_children + for_items

  let fits page_num key value =
    let new_page = inserted page_num key value None in
    let size = calculate_page_size new_page in
    size <= 4096

  let split page_num key value =
    let new_page = inserted page_num key value None in
    let sizes = List.map calculate_item_size new_page.items in
    let cumulative_sizes =
      List.fold_left
        (fun acc x ->
          match acc with
          | f :: acc -> (x + f) :: f :: acc
          | _ -> failwith "impossible")
        [ 0 ] sizes
      |> List.rev |> List.tl
    in
    let total_items_size = calculate_items_size new_page.items in
    let mid_item_index =
      match
        List.find_index (fun x -> x > total_items_size / 2) cumulative_sizes
      with
      | None -> failwith "mid index cannot be found"
      | Some x -> x
    in
    let left_items, middle_item, right_items =
      Utils.List.split_with_middle mid_item_index new_page.items
    in
    let left_children, right_children =
      match List.is_empty new_page.child_page_numbers with
      | true -> ([], [])
      | false ->
          Utils.List.split (mid_item_index + 1) new_page.child_page_numbers
    in
    let left_page =
      {
        is_from_id = true;
        child_page_numbers = left_children;
        items = left_items;
      }
    in
    let right_page =
      {
        is_from_id = true;
        child_page_numbers = right_children;
        items = right_items;
      }
    in
    let m1, m2 = middle_item in
    let middle_item = (m2, m1) in
    S.update_translation_page page_num left_page;
    let right_page_num = S.add_translation_page right_page in
    (page_num, middle_item, right_page_num)

  let create_new_root (p1, item, p2) =
    let i1, i2 = item in
    let item = (i2, i1) in
    let new_page =
      { is_from_id = true; child_page_numbers = [ p1; p2 ]; items = [ item ] }
    in
    S.add_root_translation_from_value_page new_page
end
