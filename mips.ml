(* --- mips.ml --- *)

type reg = | V0 | A0 | A1 | T0 | T1 | SP | FP | Zero | RA

type label = string

type instr =
  | Li    of reg * int
  | Addiu of reg * reg * int
  | Sw    of reg * int * reg
  | Lw    of reg * int * reg

  | Addu  of reg * reg * reg
  | Subu  of reg * reg * reg
  | Mul   of reg * reg * reg
  | Div   of reg * reg
  | Mflo  of reg
  | Mfhi  of reg

  | And   of reg * reg * reg
  | Or    of reg * reg * reg
  | Xor   of reg * reg * reg
  | Xori  of reg * reg * int
  | Slt   of reg * reg * reg
  | Sltiu of reg * reg * int
  
  | La of reg * label
  | Move of reg * reg
  | Syscall
  | Label of label
  | Beq of reg * reg * label
  | J of label | Jr of reg
  | Jal   of label

type directive =
  | Asciiz of string
  | Space of int

type decl = label * directive
type asm = { text: instr list ; data: decl list }

let ps = Printf.sprintf

let fmt_reg = function
  | V0 -> "$v0"
  | A0 -> "$a0"
  | A1 -> "$a1"
  | T0 -> "$t0"
  | T1 -> "$t1"
  | SP -> "$sp"
  | FP -> "$fp"
  | Zero -> "$zero"
  | RA -> "$ra"

let fmt_instr = function
  | Li (r, i) -> ps "  li %s, %d" (fmt_reg r) i
  | Addiu (rd, rs, imm) -> ps " addiu %s, %s, %d" (fmt_reg rd) (fmt_reg rs) imm
  | Sw (rt, off, base) -> ps " sw %s, %d(%s)" (fmt_reg rt) off (fmt_reg base)
  | Lw (rt, off, base) -> ps " lw %s, %d(%s)" (fmt_reg rt) off (fmt_reg base)

  | Addu (rd, rs, rt) -> ps " addu %s, %s, %s" (fmt_reg rd) (fmt_reg rs) (fmt_reg rt)
  | Subu (rd, rs, rt) -> ps " subu %s, %s, %s" (fmt_reg rd) (fmt_reg rs) (fmt_reg rt)
  | Mul (rd, rs, rt) -> ps " mul %s, %s, %s" (fmt_reg rd) (fmt_reg rs) (fmt_reg rt)
  | Div (rs, rt) -> ps " div %s, %s" (fmt_reg rs) (fmt_reg rt)
  | Mflo r -> ps " mflo %s" (fmt_reg r)
  | Mfhi r -> ps " mfhi %s" (fmt_reg r)

  | And (rd, rs, rt) -> ps " and %s, %s, %s" (fmt_reg rd) (fmt_reg rs) (fmt_reg rt)
  | Or (rd, rs, rt) -> ps " or %s, %s, %s" (fmt_reg rd) (fmt_reg rs) (fmt_reg rt)
  | Xor (rd, rs, rt) -> ps " xor %s, %s, %s" (fmt_reg rd) (fmt_reg rs) (fmt_reg rt)
  | Xori (rd, rs, i) -> ps " xori %s, %s, %d" (fmt_reg rd) (fmt_reg rs) i
  | Slt (rd, rs, rt) -> ps " slt %s, %s, %s" (fmt_reg rd) (fmt_reg rs) (fmt_reg rt)
  | Sltiu (rd, rs, i) -> ps " sltiu %s, %s, %d" (fmt_reg rd) (fmt_reg rs) i

  | La (r, l) -> ps " la %s, %s" (fmt_reg r) l
  | Move (r1, r2) -> ps " move %s, %s" (fmt_reg r1) (fmt_reg r2)
  | Syscall -> " syscall"

  | Label l -> ps "%s:" l
  | Beq (r1, r2, l) -> ps "  beq %s, %s, %s" (fmt_reg r1) (fmt_reg r2) l
  | J l -> ps " j %s" l
  | Jal (l) -> ps " jal %s" l
  | Jr r -> ps " jr %s" (fmt_reg r)
  
let fmt_dir = function
  | Asciiz s -> ps ".asciiz \"%s\"" s
  | Space n  -> ps ".space %d" n
    
let emit oc asm =
  Printf.fprintf oc ".text\n.globl main\nmain:\n";
  List.iter (fun i -> Printf.fprintf oc "%s\n" (fmt_instr i)) asm.text;
  Printf.fprintf oc "\n.data\n";
  List.iter (fun (l, d) -> Printf.fprintf oc "%s: %s\n" l (fmt_dir d)) asm.data