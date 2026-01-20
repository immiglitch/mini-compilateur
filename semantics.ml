exception Error of string * Lexing.position

type ty = TInt | TBool | TString
module Env = Map.Make(String)
let err pos msg = raise (Error (msg, pos))

let rec analyze_expr (env : ty Env.t) (e : Ast.Syntax.expr) : ty * Ast.IR.expr =
    match e with
    | Ast.Syntax.Int n -> (TInt,  Ast.IR.Int n.value)
    | Ast.Syntax.Bool b -> (TBool, Ast.IR.Bool b.value)
    | Ast.Syntax.String s -> (TString, Ast.IR.String s.value)
    | Ast.Syntax.Var v -> (
        match Env.find_opt v.name env with
        | None -> err v.pos ("unknown variable: " ^ v.name)
        | Some t -> (t, Ast.IR.Var v.name)
        )
    | Ast.Syntax.Call c ->
        begin match c.func, c.args with
        (* Arithmétique *)
        | ("_add" | "_sub" | "_mul" | "_div" | "_mod"), [a; b] ->
            let (t1, ir1) = analyze_expr env a in
            let (t2, ir2) = analyze_expr env b in
            if t1 <> TInt || t2 <> TInt then err c.pos "arithmetic expects integers";
            (TInt, Ast.IR.Call (c.func, [ir1; ir2]))
        (* Comparaisons *)
        | ("_lt" | "_gt" | "_le" | "_ge"), [a; b] ->
            let (t1, ir1) = analyze_expr env a in
            let (t2, ir2) = analyze_expr env b in
            if t1 <> TInt || t2 <> TInt then err c.pos "comparison expects integers";
            (TBool, Ast.IR.Call (c.func, [ir1; ir2]))
        (* Égalité *)
        | ("_eq" | "_neq"), [a; b] ->
            let (t1, ir1) = analyze_expr env a in
            let (t2, ir2) = analyze_expr env b in
            if t1 <> t2 then err c.pos "equality expects same types";
            (TBool, Ast.IR.Call (c.func, [ir1; ir2]))
        (* Logique *)
        | ("_and" | "_or" | "_xor"), [a; b] ->
            let (t1, ir1) = analyze_expr env a in
            let (t2, ir2) = analyze_expr env b in
            if t1 <> TBool || t2 <> TBool then err c.pos "logic expects booleans";
            (TBool, Ast.IR.Call (c.func, [ir1; ir2]))
        | "_not", [a] ->
            let (t, ir) = analyze_expr env a in
            if t <> TBool then err c.pos "not expects boolean";
            (TBool, Ast.IR.Call ("_not", [ir]))
        (* I/O *)
        | "_puti", [a] ->
            let (t, ir) = analyze_expr env a in
            if t <> TInt then err c.pos "printi expects int";
            (TInt, Ast.IR.Call ("_puti", [ir]))

        | "_putb", [a] ->
            let (t, ir) = analyze_expr env a in
            if t <> TBool then err c.pos "printb expects boolean";
            (TInt, Ast.IR.Call ("_putb", [ir]))

        | "print_string", [a] ->
            let (t, ir) = analyze_expr env a in
            if t <> TString then err c.pos "print_string expects string";
            (TInt, Ast.IR.Call ("print_string", [ir]))
        | "_gets", [] -> (TString, Ast.IR.Call ("_gets", []))
        | "_geti", [] -> (TInt, Ast.IR.Call ("_geti", []))
        | "_getb", [] -> (TBool, Ast.IR.Call ("_getb", []))
        | "print_newline", [] -> (TInt, Ast.IR.Call ("print_newline", []))
        | f, _ -> err c.pos ("unknown function: " ^ f)
        end
and analyze_instr (env : ty Env.t) (i : Ast.Syntax.instr) : ty Env.t * Ast.IR.instr =

    match i with
    | Ast.Syntax.Decl d ->
        let (t, ir_e) = analyze_expr env d.init in
        (Env.add d.name t env, Ast.IR.Decl (d.name, ir_e))
    | Ast.Syntax.Assign a ->
        let t_var = match Env.find_opt a.name env with
            | Some t -> t
            | None -> err a.pos ("unknown variable: " ^ a.name)
        in
        let (t_rhs, ir_rhs) = analyze_expr env a.rhs in
        if t_var <> t_rhs then err a.pos "type mismatch in assignment";
        (env, Ast.IR.Assign (a.name, ir_rhs))
    | Ast.Syntax.While w ->
        let (t_cond, ir_cond) = analyze_expr env w.cond in
        if t_cond <> TBool then err w.pos "condition must be bool";
        let (_, ir_body) = analyze_block env w.body in
        (env, Ast.IR.While (ir_cond, ir_body))
    | Ast.Syntax.Cond c ->
        let (t_cond, ir_cond) = analyze_expr env c.cond in
        if t_cond <> TBool then err c.pos "condition must be bool"; 
        let (_, ir_thn) = analyze_block env c.thn in
        let (_, ir_els) = analyze_block env c.els in
        (env, Ast.IR.Cond (ir_cond, ir_thn, ir_els))
    | Ast.Syntax.Return r ->
        let (_, ir_e) = analyze_expr env r.e in
        (env, Ast.IR.Return ir_e)
    | Ast.Syntax.Expr e ->
        let (_, ir_e) = analyze_expr env e.e in
        (env, Ast.IR.Expr ir_e)

and analyze_block (env : ty Env.t) (b : Ast.Syntax.block) : ty Env.t * Ast.IR.block =
    match b with
    | [] -> (env, [])
    | i :: rest ->
        let (env2, ir_i) = analyze_instr env i in
        let (env3, ir_rest) = analyze_block env2 rest in
        (env3, ir_i :: ir_rest)
let analyze (prog : Ast.Syntax.instr list) : Ast.IR.block =
  let (_, ir_prog) = analyze_block Env.empty prog in
  ir_prog