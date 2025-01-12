open File_management

let () =
  if Array.length Sys.argv <> 2 then
    raise (Failure "Incorrect number of arguments")
  else
    let path = Sys.argv.(1) in
    let db_desc = File_basic.initialize path in
    Network.Server.run 8080 db_desc
