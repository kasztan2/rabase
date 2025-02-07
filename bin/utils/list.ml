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

let split_half_and_copy l =
  let half = List.length l / 2 in
  let xs = List.take half l in
  let ys = List.drop half l in
  let med = List.hd ys in
  (xs, med, ys)

let split n l = (List.take n l, List.drop n l)
