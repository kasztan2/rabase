type row = Stdint.uint64 list

let show_row (r : row) =
  let l = List.map (fun i -> Stdint.Uint64.to_string i) r in
  List.fold_right (fun x acc -> x ^ acc) l ""

let pp_row fmt (r : row) = Format.fprintf fmt "Row: %s" (show_row r)

type dataframe = { var_names : string list; rows : row list } [@@deriving show]
