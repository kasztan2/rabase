open Types.Basic

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

let from_uint16 v =
  let buff = Bytes.create 2 in
  Stdint.Uint16.to_bytes_big_endian v buff 0;
  buff

let to_uint16 bts = Stdint.Uint16.of_bytes_big_endian bts 0

let from_uint32 v =
  let buff = Bytes.create 4 in
  Stdint.Uint32.to_bytes_big_endian v buff 0;
  buff

let to_uint32 bts = Stdint.Uint32.of_bytes_big_endian bts 0

let from_float v =
  let buff = Bytes.create 8 in
  let i64 = Int64.bits_of_float v in
  (try Stdint.Int64.to_bytes_big_endian i64 buff 0
   with Invalid_argument msg -> failwith msg);
  buff

let to_float bts = Stdint.Int64.of_bytes_big_endian bts 0 |> Int64.float_of_bits
let from_string = String.to_bytes
let to_string = String.of_bytes
let from_bool v = Bytes.make 1 (match v with true -> '\001' | false -> '\000')

let to_bool bts =
  let b = Bytes.get bts 0 in
  b <> '\000'

let from_char v = Bytes.make 1 v
let to_char bts = Bytes.get bts 0

let to_bytes : type a. a basic_types -> a -> bytes =
 fun t v ->
  match t with
  | T_Uint64 _ -> from_uint64 v
  | T_Int64 _ -> from_int64 v
  | T_Uint16 _ -> from_uint16 v
  | T_Uint32 _ -> from_uint32 v
  | T_Float _ -> from_float v
  | T_String _ -> from_string v
  | T_Bool _ -> from_bool v
  | T_Char _ -> from_char v

let from_bytes : type a. a basic_types -> bytes -> a =
 fun t b ->
  match t with
  | T_Uint64 _ -> to_uint64 b
  | T_Int64 _ -> to_int64 b
  | T_Uint16 _ -> to_uint16 b
  | T_Uint32 _ -> to_uint32 b
  | T_Float _ -> to_float b
  | T_String _ -> to_string b
  | T_Bool _ -> to_bool b
  | T_Char _ -> to_char b
