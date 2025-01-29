type index_type_kind = Data | ID2val | Val2ID

val get_kind : Stdint.uint16 -> index_type_kind
val get_key_length : Stdint.uint16 -> int option
