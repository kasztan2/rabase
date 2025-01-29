{
open Parser

exception SyntaxError of string
}

let int = ['1'-'9'] ['0'-'9']*

let word = ['a'-'z']+

let iriref = word (('.'|'/') word)*

let white = [' ' '\t']+

let var = "?" word

rule read =
    parse
    | white { read lexbuf }
    | "SELECT" {SELECT}
    | "DISTINCT" {DISTINCT}
    | "WHERE" {WHERE}
    | "LIMIT" {LIMIT}
    | "INSERT" {INSERT}
    | "DATA" {DATA}
    | "DELETE" {DELETE}
    | "CLEAR" {CLEAR}
    | "{" {LBRACE}
    | "}" {RBRACE}
    | "*" {STAR}
    | "." {DOT}
    | int {INTEGER (int_of_string (Lexing.lexeme lexbuf))}
    | iriref {IRIREF (Lexing.lexeme lexbuf)}
    | var {VAR (let l=Lexing.lexeme lexbuf in String.sub l 1 ((String.length l)-1))}
    | eof {EOF}
    | _ { raise (SyntaxError ("Illegal character: "^Lexing.lexeme lexbuf)) }