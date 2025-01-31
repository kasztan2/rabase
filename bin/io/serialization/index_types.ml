type index_type_kind = Data | ID2val | Val2ID

let ( <* ) x y = Stdint.Uint16.compare x (Stdint.Uint16.of_int y) == -1
let get_kind n = if n <* 6 then Data else if n <* 262 then ID2val else Val2ID
let fixed_lengths = [ Some 256; Some 8; None; Some 1; Some 8; Some 8 ]
let ( -* ) x y = Stdint.Uint16.to_int x - y

let remove_offset n =
  if n <* 6 then Stdint.Uint16.to_int n
  else if n <* 262 then n -* 6
  else n -* 262

let get_key_length n =
  match get_kind n with
  | Data -> None
  | ID2val -> Some 8
  | Val2ID -> (
      let t = remove_offset n in
      try List.nth fixed_lengths t with Failure _ -> failwith "Unknown type")
