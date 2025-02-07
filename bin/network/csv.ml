let row_to_string row =
  List.map (fun x -> Types.Basic.show_basic_types x) row |> String.concat ","

let res_to_csv (header, rows) =
  let rows_text = List.map row_to_string rows |> String.concat "\n" in
  let header_text = String.concat "," header in
  header_text ^ "\n" ^ rows_text
