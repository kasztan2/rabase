type _ eff +=
  | ReadFile : in_channel * int * int -> bytes eff
  | WriteFile : out_channel * int * bytes -> unit eff

val read_file : in_channel -> int -> int -> bytes
val write_file : out_channel -> int -> bytes -> unit
