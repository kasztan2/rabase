open Lwt.Syntax
open Alcotest

let port = 8081

let setup_server () =
  let app = Network.Server.create_app port in
  Lwt.async (fun () ->
      Opium.App.run_command' app |> function
      | `Ok t -> t
      | _ -> failwith "server not running");
  Lwt_unix.sleep 0.5

let send_query q =
  let url =
    Format.asprintf "http://localhost:%d/?query=%s" port (Uri.pct_encode q)
  in
  let* raw_res = Ezcurl_lwt.get ~url () in
  let { code; body; _ } : Ezcurl_lwt.response =
    match raw_res with Error _ -> failwith "error" | Ok x -> x
  in
  check int "Status code is 200" 200 code;
  Lwt.return (code, body)

let clear () = send_query "CLEAR"

let insert x y z =
  send_query @@ Format.asprintf "INSERT DATA {%s %s %s .}" x y z

let select_all () = send_query "SELECT ?x ?y ?z {?x ?y ?z .}"
