open Page_handler
open Types.Page_types
module S = Storage

type opt_triple =
  Stdint.uint64 option * Stdint.uint64 option * Stdint.uint64 option

module type TripleOrder = sig
  val index_type : int
  val compare : opt_triple -> opt_triple -> int
end

module UniversalDataHandle (O : TripleOrder) : DataPageHandler = struct
  type page_type = Stdint.uint32

  let get_root () = S.get_root O.index_type

  let is_leaf page_num =
    let page = S.get_data_page page_num in
    List.is_empty page.child_page_numbers

  let opt_tr_to_tr opt_tr =
    match opt_tr with
    | Some x, Some y, Some z -> (x, y, z)
    | _ -> failwith "cannot convert None to uint64"

  let tr_to_opt_tr (x, y, z) = (Some x, Some y, Some z)

  let rec get_vals_sibl page opt_tr =
    match page.sibling_page_number with
    | Some x -> get_vals_helper x opt_tr
    | None -> []

  and get_vals_helper page_num opt_tr =
    let page = S.get_data_page page_num in
    let trs = List.map tr_to_opt_tr page.triples in
    match List.is_empty page.triples with
    | true -> get_vals_sibl page opt_tr
    | false -> (
        let res = List.filter (fun x -> O.compare x opt_tr == 0) trs in
        match List.find_opt (fun x -> O.compare x opt_tr > 0) trs with
        | None -> List.append res (get_vals_sibl page opt_tr)
        | Some _ -> res)

  and get_vals page_num opt_tr =
    get_vals_helper page_num opt_tr |> List.map opt_tr_to_tr

  let get_child page_num opt_tr =
    if is_leaf page_num then failwith "cannot get a child of a leaf";
    let page = S.get_data_page page_num in
    let ind =
      match
        List.map tr_to_opt_tr page.triples
        |> List.find_index (fun x -> O.compare opt_tr x >= 0)
      with
      | None -> List.length page.triples
      | Some x -> x
    in
    try Some (List.nth page.child_page_numbers ind) with Failure _ -> None

  let one_triple_fits page_num =
    let page = S.get_data_page page_num in
    let total_size =
      3
      + (List.length page.child_page_numbers * 4)
      + 4
      + (List.length page.triples * 24)
    in
    total_size < 4096 - 28

  let create_new_root (p1, tr, p2) =
    let page =
      {
        index_type = O.index_type;
        child_page_numbers = [ p1; p2 ];
        sibling_page_number = None;
        triples = [ tr ];
      }
    in
    let page_num = S.add_data_page page in
    S.change_root O.index_type page_num

  let insert page_num ?two_children tr =
    let page = S.get_data_page page_num in
    let opt_tr = tr_to_opt_tr tr in
    let ind =
      match
        List.map tr_to_opt_tr page.triples
        |> List.find_index (fun x -> O.compare opt_tr x > 0)
      with
      | Some i -> i
      | None -> List.length page.triples
    in
    let new_triples = Utils.List.insert_at ind tr page.triples in
    let new_child_page_numbers =
      match two_children with
      | Some (l, r) -> (
          match List.length page.child_page_numbers with
          | 0 -> [ l; r ]
          | 1 -> failwith "impossible"
          | _ ->
              Utils.List.insert_at ind l page.child_page_numbers
              |> Utils.List.modify_at_pos (ind + 1) r)
      | None -> page.child_page_numbers
    in
    let new_page =
      {
        index_type = O.index_type;
        child_page_numbers = new_child_page_numbers;
        sibling_page_number = page.sibling_page_number;
        triples = new_triples;
      }
    in
    S.update_data_page page_num new_page

  let split page_num tr =
    insert page_num tr;
    let page = S.get_data_page page_num in
    let l_triples, med, r_triples =
      match is_leaf page_num with
      | true -> Utils.List.split_half_and_copy page.triples
      | false ->
          Utils.List.split_with_middle
            (List.length page.triples / 2)
            page.triples
    in
    let on_left = List.length l_triples in
    let l_children, r_children =
      Utils.List.split (on_left + 1) page.child_page_numbers
    in
    let r_page_num =
      S.add_data_page
        {
          index_type = O.index_type;
          child_page_numbers = r_children;
          triples = r_triples;
          sibling_page_number = page.sibling_page_number;
        }
    in
    let l_page_num =
      S.add_data_page
        {
          index_type = O.index_type;
          child_page_numbers = l_children;
          sibling_page_number = Some r_page_num;
          triples = l_triples;
        }
    in
    (l_page_num, med, r_page_num)
end

let opt_tr_compare (a, b, c) (x, y, z) =
  let p = match (a, x) with Some a, Some x -> compare a x | _ -> 0 in
  match p with
  | 0 -> (
      let q = match (b, y) with Some b, Some y -> compare b y | _ -> 0 in
      match q with
      | 0 -> ( match (c, z) with Some c, Some z -> compare c z | _ -> 0)
      | _ -> q)
  | _ -> p

let rearr_tr (a, b, c) ord =
  let arr = [ a; b; c ] in
  match List.length ord with
  | 3 ->
      let a = List.map (fun x -> List.nth arr x) ord in
      (List.nth a 0, List.nth a 1, List.nth a 2)
  | _ -> failwith "rearr_tr"

let wrap_compare ord a b = opt_tr_compare (rearr_tr a ord) (rearr_tr b ord)

module DataSPO = UniversalDataHandle (struct
  let index_type = 0
  let compare = opt_tr_compare
end)

module DataSOP = UniversalDataHandle (struct
  let index_type = 1
  let compare = wrap_compare [ 0; 2; 1 ]
end)

module DataPSO = UniversalDataHandle (struct
  let index_type = 2
  let compare = wrap_compare [ 1; 0; 2 ]
end)

module DataPOS = UniversalDataHandle (struct
  let index_type = 3
  let compare = wrap_compare [ 1; 2; 0 ]
end)

module DataOSP = UniversalDataHandle (struct
  let index_type = 4
  let compare = wrap_compare [ 2; 0; 1 ]
end)

module DataOPS = UniversalDataHandle (struct
  let index_type = 5
  let compare = wrap_compare [ 2; 1; 0 ]
end)
