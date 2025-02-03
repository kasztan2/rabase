open Stdlib

(** insert_at pos el l - inserts 'el' at index 'pos' in 'l' *)
let insert_at pos el l =
  let xs = List.take pos l in
  let ys = List.drop pos l in
  let ys = el :: ys in
  List.append xs ys

let modify_at_pos pos new_value l =
  List.mapi (fun i x -> if i == pos then new_value else x) l

let split_with_middle pos l =
  let left = List.take pos l in
  let right = List.drop (pos + 1) l in
  let m = List.nth l pos in
  (left, m, right)

let split n l = (List.take n l, List.drop n l)
