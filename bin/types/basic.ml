type basic_types =
  | T_Iri of string
  | T_Uint64 of Stdint.uint64
  | T_Uint32 of Stdint.uint32
  | T_Uint16 of Stdint.uint16
  | T_Int64 of int64
  | T_Float of float
  | T_String of string
  | T_Bool of bool
  | T_Char of char

let pp_basic_types fmt b =
  match b with
  | T_Iri s -> Format.fprintf fmt "T_Iri %S" s
  | T_Uint64 u -> Format.fprintf fmt "T_Uint64 %s" (Stdint.Uint64.to_string u)
  | T_Uint32 u -> Format.fprintf fmt "T_Uint32 %s" (Stdint.Uint32.to_string u)
  | T_Uint16 u -> Format.fprintf fmt "T_Uint16 %s" (Stdint.Uint16.to_string u)
  | T_Int64 i -> Format.fprintf fmt "T_Int64 %Ld" i
  | T_Float f -> Format.fprintf fmt "T_Float %f" f
  | T_String s -> Format.fprintf fmt "T_String %S" s
  | T_Bool b -> Format.fprintf fmt "T_Bool %b" b
  | T_Char c -> Format.fprintf fmt "T_Char '%c'" c

let show_basic_types b =
  match b with
  | T_Iri s -> s
  | T_Uint64 x -> Stdint.Uint64.to_string x
  | T_Uint32 x -> Stdint.Uint32.to_string x
  | T_Uint16 x -> Stdint.Uint16.to_string x
  | T_Int64 x -> Int64.to_string x
  | T_Float x -> Float.to_string x
  | T_String s -> s
  | T_Bool b -> Bool.to_string b
  | T_Char c -> String.make 1 c
