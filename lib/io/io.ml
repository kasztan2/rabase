open Effect
open Effect.Deep

type _ Effect.t +=
  | ReadFile : in_channel * int * int -> bytes t
  | WriteFile : out_channel * int * bytes -> unit t

let read_file ic offset n =
  try perform (ReadFile (ic, offset, n))
  with effect ReadFile (ic, offset, n), k ->
    continue k
      (seek_in ic offset;
       let buf = Bytes.create n in
       really_input ic buf 0 n;
       buf)

let write_file oc offset bts =
  try perform (WriteFile (oc, offset, bts))
  with effect WriteFile (oc, offset, bts), k ->
    continue k
      (seek_out oc offset;
       output_bytes oc bts)
