open File_management.File_basic

let run port {ic; oc} =
  close_in ic;
  close_out oc;
  print_int port
