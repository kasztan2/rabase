let output_int64 oc x =
  List.init 8 (fun i ->
      (Int64.shift_right_logical x (i * 8) |> Int64.to_int) land 0xFF)
  |> List.rev
  |> List.iter (fun b -> Out_channel.output_byte oc b)

let input_int64 ic =
  List.init 8 (fun _ -> In_channel.input_byte ic)
  |> List.map (fun x ->
         match x with
         | None -> failwith "cannot read int64"
         | Some x -> Int64.of_int x)
  |> List.fold_left (fun acc x -> Int64.logor (Int64.shift_left acc 8) x) 0L
