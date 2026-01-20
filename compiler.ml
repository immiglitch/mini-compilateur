open Ast.IR
open Mips

module Env = Map.Make(String)
type env = int Env.t

let fresh_label = let c = ref 0 in fun base -> incr c; Printf.sprintf "%s_%d" base !c
let fresh_str_label = let c = ref 0 in fun () -> incr c; Printf.sprintf "str_%d" !c

let rec compile_expr (env : env) (e : expr) : instr list * decl list =
    match e with
    | Int n    -> ([ Li (V0, n) ], [])
    | Bool b   -> ([ Li (V0, if b then 1 else 0) ], [])
    | Var x    -> ([ Lw (V0, Env.find x env, FP) ], [])
    | String s -> let l = fresh_str_label () in ([ La (V0, l) ], [ (l, Asciiz s) ])
    | Call (f, args) ->
            let (c_args, d_args) = List.fold_right (fun arg (acc_c, acc_d) ->
                let (ca, da) = compile_expr env arg in
                (ca @ [ Addiu (SP, SP, -4); Sw (V0, 0, SP) ] @ acc_c, da @ acc_d)
            ) args ([], []) in
            let target = match f with "_lt" -> "_inf" | "_gt" -> "_sup" | n -> n in
            (c_args @ [ Jal target; Addiu (SP, SP, 4 * List.length args) ], d_args)

let rec compile_block_term (env : env) (next_off : int) (b : block) =
    match b with
    | [] -> ([ Li (V0, 0) ], [])
    
    | Decl (name, init) :: tl ->
        let (ci, di) = compile_expr env init in
        let off = next_off - 4 in
        let (ct, dt) = compile_block_term (Env.add name off env) off tl in
        (ci @ [ Addiu (SP, SP, -4); Sw (V0, 0, SP) ] @ ct, di @ dt)
    | Assign (name, rhs) :: tl ->
        let (cr, dr) = compile_expr env rhs in
        let (ct, dt) = compile_block_term env next_off tl in
        (cr @ [ Sw (V0, Env.find name env, FP) ] @ ct, dr @ dt)
    | Cond (c, thn, els) :: tl ->
        let l_else, l_end = fresh_label "else", fresh_label "endif" in
        let (cc, dc), (cthn, dthn), (cels, dels), (ct, dt) = 
          compile_expr env c, compile_block_term env next_off thn, 
          compile_block_term env next_off els, compile_block_term env next_off tl in
        (cc @ [ Beq (V0, Zero, l_else) ] @ cthn @ [ J l_end; Label l_else ] @ cels @ [ Label l_end ] @ ct, dc @ dthn @ dels @ dt)
    | While (c, body) :: tl ->
        let l_start, l_end = fresh_label "while", fresh_label "endwhile" in
        let (cc, dc), (cb, db), (ct, dt) = compile_expr env c, compile_block_term env next_off body, compile_block_term env next_off tl in
        ([ Label l_start ] @ cc @ [ Beq (V0, Zero, l_end) ] @ cb @ [ J l_start; Label l_end ] @ ct, dc @ db @ dt)
        
    | Return e :: _ -> 
        let (ce, de) = compile_expr env e in 
        (ce @ [ 
            Move (SP, FP);
            Lw (RA, 0, SP);
            Lw (FP, 4, SP);
            Addiu (SP, SP, 8);
            Jr RA              
        ], de)
    | Expr e :: tl -> let (ce, de), (ct, dt) = compile_expr env e, compile_block_term env next_off tl in (ce @ ct, de @ dt)


let compile (ir : block) : Mips.asm =
  let (code, data) = compile_block_term Env.empty 0 ir in
  let data_builtins = [ 
    ("bool_true", Asciiz "true");
    ("bool_false", Asciiz "false"); 
    ("global_string_reader", Space 128)
  ] in
  { text = 
      (* prologue *)
      [ Addiu (SP, SP, -8);
        Sw (FP, 4, SP);      
        Sw (RA, 0, SP);      
        Move (FP, SP) ]      
      @ code
      (* épilogue *)
      @ [ Move (SP, FP);
          Lw (RA, 0, SP);
          Lw (FP, 4, SP);
          Addiu (SP, SP, 8);
          Jr RA ]
      @ Baselib.builtins;
    data = data_builtins @ data }