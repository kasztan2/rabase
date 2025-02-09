open Lwt.Infix
open Lwt.Syntax
open Lwt.Let_syntax
open Alcotest

let setup_server () =
  let port = 8081 in
  let app = Network.Server.create_app port in
  Lwt.async (fun () ->
      Opium.App.run_command' app |> function `Ok t -> t | _ -> Lwt.return_unit);
  Lwt_unix.sleep 0.5
(*
  let uri =
    Uri.of_string (Printf.sprintf "http://localhost:%d/?query=%s" port
                     (Uri.pct_encode "SELECT ?a ?b ?c { ?a ?b ?c . }"))
  in
  let%lwt (resp, body) = Cohttp_lwt_unix.Client.get uri in
  let status = Cohttp.Response.status resp |> Cohttp.Code.code_of_status in
  Alcotest.(check int) "status code" 200 status;
  Cohttp_lwt.Body.to_string body >>= fun body_str ->
  Alcotest.(check string) "response body" "expected output" body_str;
  Lwt.return_unit *)

let () =
  Alcotest_lwt.run "Integration tests"
    [
      ( "server",
        [
          Alcotest_lwt.test_case "Integration: select query" `Quick
            test_server_integration;
        ] );
    ]
