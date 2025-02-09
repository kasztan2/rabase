type row = Stdint.uint64 list
type dataframe = { var_names : string list; rows : row list }

val pp_row : Format.formatter -> row -> unit
val show_row : row -> string
val pp_dataframe : Format.formatter -> dataframe -> unit
val show_dataframe : dataframe -> string
