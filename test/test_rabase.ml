open Lwt.Syntax
open Lwt.Infix
open Alcotest
open Server_utils

let test_basic _ () =
  let* _ = clear () in
  let* _ = insert "a" "b" "c" in
  let* _, data = select_all () in
  check string "Select returns expected output" "x,y,z\na,b,c" data;
  Lwt.return_unit

let test_seq_inserts _ () =
  let* _ = clear () in
  let perform_insert x =
    let* _ = insert "a" "b" (string_of_int x) in
    Lwt.return_unit
  in
  Random.init 0;
  let l =
    List.init 10000 (fun x -> x)
    |> List.map (fun x -> (Random.bits (), x))
    |> List.sort compare |> List.map snd
  in
  let* _ = Lwt_list.iter_s perform_insert l in
  let* _, data = select_all () in
  let data = data |> String.split_on_char '\n' in
  let header = List.hd data in
  let rows = List.tl data in
  check string "csv header correct" "x,y,z" header;
  check int "10000 triples inserted" 10000 (List.length rows);
  Lwt.return_unit

let test_insert_nums _ () =
  let* _ = clear () in
  let insert_repr x =
    let* _ = insert ("n" ^ string_of_int x) "hasValue" (string_of_int x) in
    Lwt.return_unit
  in
  let insert_div x =
    let divs =
      List.init x (fun i -> i + 1) |> List.filter (fun i -> x mod i == 0)
    in
    let perform_insert y =
      let* _ =
        insert ("n" ^ string_of_int x) "hasDivisor" ("n" ^ string_of_int y)
      in
      Lwt.return_unit
    in
    Lwt_list.iter_s perform_insert divs
  in
  let lst = List.init 10 (fun i -> i + 1) in
  let* _ = Lwt_list.iter_s insert_repr lst in
  let* _ = Lwt_list.iter_s insert_div lst in
  let* _, raw_data =
    send_query "SELECT ?x WHERE {?x hasDivisor ?y . ?y hasValue 2 .}"
  in
  let data = raw_data |> String.split_on_char '\n' in
  let _ = List.hd data in
  let _ = List.tl data in
  check string "e" "" raw_data;
  Lwt.return_unit

let () =
  Lwt_main.run
    ( setup_server () >>= fun () ->
      Alcotest_lwt.run "Rabase"
        [
          ( "Query tests",
            [
              Alcotest_lwt.test_case "One insert and select" `Quick test_basic;
              Alcotest_lwt.test_case "10000 inserts" `Quick test_seq_inserts;
              Alcotest_lwt.test_case "Numbers dataset" `Quick test_insert_nums;
            ] );
        ] )
