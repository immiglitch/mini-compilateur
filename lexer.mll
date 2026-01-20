{
  (*open Lexing*)
  open Parser
  exception Error of char
}

let num = ['0'-'9']+
let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule token = parse
| eof             { Lend }
| [ ' ' '\t' ]    { token lexbuf }
| '\n'            { Lexing.new_line lexbuf; token lexbuf }

| "var"           { Ldecl Ast.TInt }
| "return"        { Lreturn }

| "true"          { Lbool true }
| "false"         { Lbool false }
| "not"           { Lnot }

| "&&"            { Land }
| "||"            { Lor }
| "xor"           { Lxor }

| "=="            { Leq }
| "<="            { Linfe }
| "<"             { Linf }
| ">"             { Lsup }

| '='             { Lassign }
| ';'             { Lsc }

| "//" [^ '\n']* { token lexbuf }

| '+'             { Ladd }
| '-'             { Lsub }
| '*'             { Lmul }
| '/'             { Ldiv }
| '('             { Lopar }
| ')'             { Lcpar }
| "mod"           { Lmod }

| "if"            { Lif }
| "else"          { Lelse }
| '{'             { Loacc }
| '}'             { Lcacc }
| "while"         { Lloop }

| "scani"          { Lgeti }
| "scans"          { Lgets }
| "getb"          { Lgetb }
| "printi"        { Lprinti }
| "printb"        { Lprintb }
| '"' ([^ '"']* as s) '"' { Lstring s }

| ident as s      { Lvar s }
| num as n        { Lint (int_of_string n) }
| _ as c          { raise (Error c) }