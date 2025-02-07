let q1 = "INSERT DATA {a b c .}"
let q2 = "SELECT ?x ?y ?z {?x ?y ?z .}"
let q3 = "INSERT DATA {d e f .}"
let q4 = "SELECT ?x ?y ?z {?z ?y ?z .}"
let queries = [ q1; q2; q3; q4 ]

let exec q =
  let parsed =
    match Sparql_parser.Parse.parse q with
    | Some x -> x
    | None -> failwith "Error: query parsing failed"
  in
  let query_plan =
    try Querying.Query_plan.make_query_plan parsed
    with Failure x -> failwith ("Error: in query planning: " ^ x)
  in
  (*print_endline (Querying.Query_plan_types.show_query_plan query_plan);*)
  let result = Querying.Execute.execute query_plan in
  print_endline (Network.Csv.res_to_csv result)
(*print_endline (Storage.debug ())*)

let () = List.iter (fun q -> exec q) queries
