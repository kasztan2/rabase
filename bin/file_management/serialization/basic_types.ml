let from_uint64 v =
  let buff = Bytes.create 8 in
  (try Stdint.Uint64.to_bytes_big_endian v buff 0
   with Invalid_argument msg -> failwith msg);
  buff

let to_uint64 bts =
  try Stdint.Uint64.of_bytes_big_endian bts 0
  with Invalid_argument msg -> failwith msg

let from_int64 v =
  let buff = Bytes.create 8 in
  Stdint.Int64.to_bytes_big_endian v buff 0;
  buff

let to_int64 bts = Stdint.Int64.of_bytes_big_endian bts 0

let from_float v =
  let buff = Bytes.create 8 in
  let i64 = Int64.bits_of_float v in
  (try Stdint.Int64.to_bytes_big_endian i64 buff 0
   with Invalid_argument msg -> failwith msg);
  buff

let to_float bts = Stdint.Int64.of_bytes_big_endian bts 0 |> Int64.float_of_bits
let from_string = String.to_bytes
let to_string = String.of_bytes

let from_bool v =
  Bytes.init 1 (fun _ -> match v with true -> '\001' | false -> '\000')

let to_bool bts =
  let b = Bytes.get bts 0 in
  b <> '\000'

type _ basic_types =
  | T_Uint64 : Stdint.uint64 -> Stdint.uint64 basic_types
  | T_Int64 : int64 -> int64 basic_types
  | T_Float : float -> float basic_types
  | T_String : string -> string basic_types
  | T_Bool : bool -> bool basic_types

let to_bytes : type a. a basic_types -> a -> bytes =
 fun t v ->
  match t with
  | T_Uint64 _ -> from_uint64 v
  | T_Int64 _ -> from_int64 v
  | T_Float _ -> from_float v
  | T_String _ -> from_string v
  | T_Bool _ -> from_bool v

let from_bytes : type a. a basic_types -> bytes -> a =
 fun t b ->
  match t with
  | T_Uint64 _ -> to_uint64 b
  | T_Int64 _ -> to_int64 b
  | T_Float _ -> to_float b
  | T_String _ -> to_string b
  | T_Bool _ -> to_bool b
