open Mips

module Env = Map.Make(String)

let _types_ = Env.empty

let builtins = [
  Label "_add"; Lw (T0, 0, SP); Lw (T1, 4, SP); Addu (V0, T0, T1); Jr RA;
  Label "_sub"; Lw (T0, 0, SP); Lw (T1, 4, SP); Subu (V0, T0, T1); Jr RA;
  Label "_mul"; Lw (T0, 0, SP); Lw (T1, 4, SP); Mul (V0, T0, T1); Jr RA;
  Label "_div"; Lw (T0, 0, SP); Lw (T1, 4, SP); Div (T0, T1); Mflo V0; Jr RA;
  Label "_mod"; Lw (T0, 0, SP); Lw (T1, 4, SP); Div (T0, T1); Mfhi V0; Jr RA;
  
  (* Opérations Logiques *)
  Label "_and"; Lw (T0, 0, SP); Lw (T1, 4, SP); And (V0, T0, T1); Jr RA;
  Label "_or";  Lw (T0, 0, SP); Lw (T1, 4, SP); Or (V0, T0, T1); Jr RA;
  Label "_not"; Lw (T0, 0, SP); Xori (V0, T0, 1); Jr RA;
  Label "_xor"; Lw (T0, 0, SP); Lw (T1, 4, SP); Xor (V0, T0, T1); Jr RA;

  (* Comparaisons *)
  Label "_sup"; Lw (T0, 0, SP); Lw (T1, 4, SP); Slt (V0, T0, T1); Jr RA;
  Label "_inf"; Lw (T0, 0, SP); Lw (T1, 4, SP); Slt (V0, T1, T0); Jr RA;
  Label "_eq";   Lw (T0, 0, SP); Lw (T1, 4, SP); Xor (T0, T0, T1); Sltiu (V0, T0, 1); Jr RA;
  Label "_puti"; Lw (A0, 0, SP); Li (V0, 1); Syscall; Li (V0, 0); Jr RA;
  Label "_geti"; Li (V0, 5); Syscall; Jr RA;
  Label "_gets"; La (A0, "global_string_reader"); Li (A1, 100); Li (V0, 8); Syscall; La (V0, "global_string_reader"); Jr RA;
  Label "_getb"; Li (V0, 5); Syscall; Jr RA;

  (* Chaînes (Pour read_int.test etc*)
  Label "print_string"; Lw (A0, 0, SP); Li (V0, 4); Syscall; Li (V0, 0); Jr RA;
  Label "_putb"; Lw (T0, 0, SP); Beq (T0, Zero, "p_false_base"); La (A0, "bool_true"); Li (V0, 4); Syscall; J "p_end_base";
  Label "p_false_base"; La (A0, "bool_false"); Li (V0, 4); Syscall; Label "p_end_base"; Li (V0, 0); Jr RA;

  Label "print_newline"; Li (A0, 10); Li (V0, 11); Syscall; Li (V0, 0); Jr RA;
]

