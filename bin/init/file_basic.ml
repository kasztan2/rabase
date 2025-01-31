open Header_template

type db_description = { ic : in_channel; oc : out_channel }

let create_db filename =
  let oc = open_out_bin filename in
  output_bytes oc header_template;
  close_out oc

let rec ensure_folders dir =
  if Sys.file_exists dir then ()
  else
    let parent = Filename.dirname dir in
    if parent <> dir then (
      ensure_folders parent;
      Sys.mkdir dir 0o755)
    else ()

let initialize path =
  let dir = Filename.dirname path in
  ensure_folders dir;
  if not (Sys.file_exists path) then create_db path;
  {
    ic = open_in_gen [ Open_rdonly; Open_binary ] 0o666 path;
    oc = open_out_gen [ Open_wronly; Open_binary ] 0o666 path;
  }
