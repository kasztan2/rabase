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
  let insert_div x =
    let divs =
      List.init x (fun i -> i + 1) |> List.filter (fun i -> x mod i == 0)
    in
    let q =
      Format.asprintf "INSERT DATA {%s}"
        (List.map (fun y -> Format.asprintf "n%d hasDivisor n%d . " x y) divs
        |> String.concat "")
    in
    let* _ = send_query q in
    Lwt.return_unit
  in
  let lst = List.init 5000 (fun i -> i + 1) in
  let repr_qs =
    list_sections 100 lst
    |> List.map (fun l ->
           Format.asprintf "INSERT DATA {%s}"
             (List.map (fun x -> Format.asprintf "n%d hasValue %d . " x x) l
             |> String.concat ""))
  in
  let* _ =
    Lwt_list.iter_s
      (fun q ->
        let* _ = send_query q in
        Lwt.return_unit)
      repr_qs
  in
  let* _ = Lwt_list.iter_s insert_div lst in
  let* _, raw_data =
    send_query
      "SELECT ?x WHERE {?x hasDivisor ?y . ?y hasValue 2 . ?x hasDivisor ?z . \
       ?z hasValue 3 .}"
  in
  let data_2_3 =
    raw_data |> String.split_on_char '\n' |> List.sort compare |> List.tl
    |> String.concat ""
  in
  let* _, raw_data =
    send_query "SELECT ?x WHERE {?x hasDivisor ?y . ?y hasValue 6 .}"
  in
  let data_6 =
    raw_data |> String.split_on_char '\n' |> List.sort compare |> List.tl
    |> String.concat ""
  in
  check string "e" data_2_3 data_6;
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
