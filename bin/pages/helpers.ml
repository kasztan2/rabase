open Types.Basic

let calculate_type_size x =
  match x with
  | T_Uint64 _ -> 8
  | T_Uint32 _ -> 4
  | T_Uint16 _ -> 2
  | T_Int64 _ -> 8
  | T_Float _ -> 8
  | T_String x -> String.length x
  | T_Bool _ -> 1
  | T_Char _ -> 1
