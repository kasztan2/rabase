open Types.Page_types
open Types.Basic
module B = Basic_types

let from_triple ((a, b, c) : triple) =
  let buff = Buffer.create 24 in
  Buffer.add_bytes buff (B.from_uint64 a);
  Buffer.add_bytes buff (B.from_uint64 b);
  Buffer.add_bytes buff (B.from_uint64 c);
  Buffer.to_bytes buff

let to_triple : bytes -> triple =
 fun bts ->
  let a = B.to_uint64 (Bytes.sub bts 0 8) in
  let b = B.to_uint64 (Bytes.sub bts 8 8) in
  let c = B.to_uint64 (Bytes.sub bts 16 8) in
  (a, b, c)

let from_di (p : data_interior_page) =
  let buf = Buffer.create 4096 in
  let add = Buffer.add_bytes buf in
  add (B.from_uint16 p.index_type);
  add (Bytes.make 1 '\000');
  add (Bytes.make 4 '\000');
  add (Bytes.make 1 (List.length p.triples |> Char.chr));
  List.map (fun num -> B.from_uint32 num) p.child_page_numbers
  |> List.iter (fun b -> add b);
  let free_bytes = 4096 - Buffer.length buf - (24 * List.length p.triples) in
  add (Bytes.make free_bytes '\000');
  List.map (fun tr -> from_triple tr) p.triples |> List.iter (fun b -> add b);
  Buffer.to_bytes buf

let to_di bts =
  let index_type = Bytes.sub bts 0 2 |> B.to_uint16 in
  let triple_count = Bytes.sub bts 7 1 |> B.to_char |> Char.code in
  let child_page_numbers =
    List.init (triple_count + 1) (fun i ->
        Bytes.sub bts (8 + (i * 4)) 4 |> B.to_uint32)
  in
  let triples =
    List.init triple_count (fun i ->
        Bytes.sub bts (4096 - (triple_count * 24) + (i * 24)) 24 |> to_triple)
  in
  { index_type; child_page_numbers; triples }

let from_dl (p : data_leaf_page) =
  let buf = Buffer.create 4096 in
  let add = Buffer.add_bytes buf in
  add (B.from_uint16 p.index_type);
  add (Bytes.make 1 '\001');
  add (B.from_uint32 p.sibling_page_number);
  add (Bytes.make 1 (List.length p.triples |> Char.chr));
  let free_bytes = 4096 - Buffer.length buf - (24 * List.length p.triples) in
  add (Bytes.make free_bytes '\000');
  List.map (fun tr -> from_triple tr) p.triples |> List.iter (fun b -> add b);
  Buffer.to_bytes buf

let to_dl bts =
  let index_type = Bytes.sub bts 0 2 |> B.to_uint16 in
  let sibling_page_number = Bytes.sub bts 3 4 |> B.to_uint32 in
  let triple_count = Bytes.sub bts 7 1 |> B.to_char |> Char.code in
  let triples =
    List.init triple_count (fun i ->
        Bytes.sub bts (4096 - (triple_count * 24) + (i * 24)) 24 |> to_triple)
  in
  { index_type; sibling_page_number; triples }

let from_ti (p: 'a translation_interior_page) =
  let buf = Buffer.create 4096 in
  let add = Buffer.add_bytes buf in
  add (B.from_uint16 p.index_type);
  add (Bytes.make 1 '\000');
  add (Bytes.make 4 '\000');
  add (List.length p.keys |> Stdint.Uint16.of_int |> B.from_uint16);
  match Data.Index_types.get_key_length p.index_type with
  | Some _ -> ...
  | None -> ...

let to_bytes : type a. a page -> a -> bytes =
 fun t v ->
  match t with
  | Page_data_interior _ -> from_di v
  | Page_data_leaf _ -> from_dl v
  | Page_translation_interior _ -> from_ti v
  | Page_translation_leaf _ -> from_tl v

let from_bytes : type a. a page -> bytes -> a =
 fun t b ->
  match t with
  | Page_data_interior _ -> to_di b
  | Page_data_leaf _ -> to_dl b
  | Page_translation_interior _ -> to_ti b
  | Page_translation_leaf _ -> to_tl b
