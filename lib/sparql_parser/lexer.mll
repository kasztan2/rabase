{
open Parser

exception SyntaxError of string
}

let int = ('-'? ['1'-'9'] ['0'-'9']*) | '0'

let word = ['a'-'z']+

let iriref_component = ['a'-'z''A'-'Z''0'-'9']+

let iriref_sep = ['.' '/' ':']+

let iriref = iriref_component (iriref_sep iriref_component)*

let white = [' ' '\t']+

let var = "?" word

let string = '"' [^'"']* '"'

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
    | int {INTEGER (Int64.of_string (Lexing.lexeme lexbuf))}
    | string {STRING (Lexing.lexeme lexbuf)}
    | iriref {IRIREF (Lexing.lexeme lexbuf)}
    | var {VAR (let l=Lexing.lexeme lexbuf in String.sub l 1 ((String.length l)-1))}
    | eof {EOF}
    | _ { raise (SyntaxError ("Illegal character: "^Lexing.lexeme lexbuf)) }