open Core
open Lexer
open Lexing

let print_position (out : Format.formatter) (lexbuf : Lexing.lexbuf) : unit =
  let pos = lexbuf.lex_curr_p in
  Format.fprintf out "%s:%d:%d" pos.pos_fname pos.pos_lnum
    (pos.pos_cnum - pos.pos_bol + 1)

let parse_with_error lexbuf =
  try Some (Parser.query_or_update Lexer.read lexbuf) with
  | SyntaxError msg ->
      let err_msg = Format.asprintf "%a: %s" print_position lexbuf msg in
      failwith err_msg
  | Parser.Error ->
      let err_msg =
        Format.asprintf "%a: syntax error\n" print_position lexbuf
      in
      failwith err_msg

let parse s =
  let lexbuf = Lexing.from_string s in
  parse_with_error lexbuf
