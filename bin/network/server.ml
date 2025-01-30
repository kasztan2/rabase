open File_management.File_basic
open Opium

let info _req = Response.of_plain_text "Rabase server" |> Lwt.return

let query_logic query_m =
  let query =
    match query_m with
    | Some x -> x
    | None -> failwith "Error: no query provided"
  in
  let parsed =
    match Sparql_parser.Parse.parse query with
    | Some x -> x
    | None -> failwith "Error: query parsing failed"
  in
  let query_plan = Querying.Query_plan.make_query_plan parsed in
  let%lwt () = Lwt_io.printl (Querying.Query_plan.show_query_plan query_plan) in
  Lwt.return "Parsed"

let query req =
  let query_m = Request.query "query" req in
  let%lwt res =
    Lwt.catch
      (fun () -> query_logic query_m)
      (fun exn -> Lwt.return (Printexc.to_string exn))
  in
  Response.of_plain_text res |> Lwt.return

let run port =
  let path_r = ref None in
  let anon_fun s = path_r := Some s in
  Arg.parse [] anon_fun "Usage: ...";
  let path =
    match !path_r with None -> failwith "no path provided" | Some p -> p
  in
  let { ic; oc } = initialize path in
  close_in ic;
  close_out oc;
  print_int port;
  App.empty |> App.get "/info" info |> App.get "/" query |> App.port port
  |> App.start_multicore
