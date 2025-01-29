val from_uint64 : Stdint.uint64 -> bytes
val to_uint64 : bytes -> Stdint.uint64
val from_int64 : int64 -> bytes
val to_int64 : bytes -> int64
val from_uint16 : Stdint.uint16 -> bytes
val to_uint16 : bytes -> Stdint.uint16
val from_uint32 : Stdint.uint32 -> bytes
val to_uint32 : bytes -> Stdint.uint32
val from_float : float -> bytes
val to_float : bytes -> float
val from_string : string -> bytes
val to_string : bytes -> string
val from_bool : bool -> bytes
val to_bool : bytes -> bool
val from_char : char -> bytes
val to_char : bytes -> char
val to_bytes : 'a Types.Basic.basic_types -> 'a -> bytes
val from_bytes : 'a Types.Basic.basic_types -> bytes -> 'a
