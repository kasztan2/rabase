type _ basic_types =
  | T_Uint64 : Stdint.uint64 -> Stdint.uint64 basic_types
  | T_Uint32 : Stdint.uint32 -> Stdint.uint32 basic_types
  | T_Uint16 : Stdint.uint16 -> Stdint.uint16 basic_types
  | T_Int64 : int64 -> int64 basic_types
  | T_Float : float -> float basic_types
  | T_String : string -> string basic_types
  | T_Bool : bool -> bool basic_types
  | T_Char : char -> char basic_types
