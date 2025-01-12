type _ basic_types =
  | T_Uint64 : Stdint.uint64 -> Stdint.uint64 basic_types
  | T_Int64 : int64 -> int64 basic_types
  | T_Float : float -> float basic_types
  | T_String : string -> string basic_types
  | T_Bool : bool -> bool basic_types

val to_bytes : 'a basic_types -> 'a -> bytes
val from_bytes : 'a basic_types -> bytes -> 'a
