open Lexing

type type_t = TInt | TBool | TString

module Syntax = struct
  type expr =
    | Int    of { value: int; pos: position }
    | Bool   of { value: bool; pos: position }
    | String of { value: string; pos: position }
    | Var    of { name: string; pos: position }
    | Call   of { func: string; args: expr list; pos: position }

  type instr =
    | Decl   of { name: string; init: expr; pos: position }
    | Assign of { name: string; rhs: expr; pos: position }
    | While  of { cond: expr; body: block; pos: position }
    | Cond   of { cond: expr; thn: block; els: block; pos: position }
    | Return of { e: expr; pos: position }
    | Expr   of { e: expr; pos: position }
  and block = instr list
  
  type def = Func of string * string list * block
  type prog = def list
end

module IR = struct
  type expr =
    | Int of int
    | Bool of bool
    | String of string
    | Var of string
    | Call of string * expr list

  type instr =
    | Decl of string * expr
    | Assign of string * expr
    | While of expr * block
    | Cond of expr * block * block
    | Return of expr
    | Expr of expr
  and block = instr list
    type def =
    | Func of string * string list * block
end