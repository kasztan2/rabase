open Init.File_basic
open Fixed_opium

let info _req = Response.of_plain_text "Rabase server" |> Lwt.return

let query_logic query_m =
  Logs.debug (fun m -> m "Getting query string");
  let query =
    match query_m with
    | Some x -> x
    | None -> failwith "Error: no query provided"
  in
  Logs.debug (fun m -> m "Parsing the query");
  let parsed =
    match Sparql_parser.Parse.parse query with
    | Some x -> x
    | None -> failwith "Error: query parsing failed"
  in
  Logs.debug (fun m -> m "Creating an execution plan");
  let query_plan =
    try Querying.Query_plan.make_query_plan parsed
    with Failure x -> failwith ("Error: in query planning: " ^ x)
  in
  Logs.debug (fun m ->
      m "Execution plan: %s"
        (Querying.Query_plan_types.show_query_plan query_plan));
  Logs.debug (fun m -> m "Executing the query");
  let result = Querying.Execute.execute query_plan in
  Logs.debug (fun m -> m "Storage state after the query: %s" (Storage.debug ()));
  Logs.debug (fun m -> m "Query result: %s" (Csv.res_to_csv result));
  Lwt.return (Csv.res_to_csv result)

let query req =
  Logs.info (fun m -> m "Received a query");
  let query_m = Request.query "query" req in
  let%lwt res =
    Lwt.catch
      (fun () -> query_logic query_m)
      (fun exn ->
        Logs.info (fun m -> m "Exception during query");
        Lwt.return (Printexc.to_string exn))
  in
  Response.of_plain_text res |> Lwt.return

let create_app port =
  App.empty |> App.get "/info" info |> App.get "/" query |> App.port port

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
  let app =
    create_app port
  in
  Logs.info (fun m -> m "Starting the server");
  match App.run_command' app with
  | `Ok (app : unit Lwt.t) -> Lwt_main.run app
  | `Error -> exit 1
  | `Not_running -> exit 0
