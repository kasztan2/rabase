type basic_types =
  | T_Uint64 of Stdint.uint64
  | T_Uint32 of Stdint.uint32
  | T_Uint16 of Stdint.uint16
  | T_Int64 of int64
  | T_Float of float
  | T_String of string
  | T_Bool of bool
  | T_Char of char
