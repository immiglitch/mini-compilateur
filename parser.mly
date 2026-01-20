%{
  (*open Ast*)
  open Ast.Syntax
%}

%token <int> Lint
%token <bool> Lbool
%token <string> Lvar
%token <string> Lstring
%token <Ast.type_t> Ldecl
%token Ladd Lsub Lmul Ldiv Lmod Loacc Lcacc Lopar Lcpar
%token Lprinti Lprintb Lgeti Lgetb Lgets
%token Land Lor Lxor Lnot
%token Linf Lsup Linfe Leq
%token Lreturn Lif Lelse Lloop Lassign Lsc Lend


%left Lor
%left Land
%left Lxor
%nonassoc Linf Lsup Linfe
%left Ladd Lsub
%left Lmul Ldiv Lmod
%left Lprinti Lprintb
%right Lnot

%start prog
%type <Ast.Syntax.block> prog
%type <Ast.Syntax.block> block

%%

prog:
    | Lend { [] }
    | i = instr; b = prog { i :: b }
;

block:
    | i = instr; b = block { i :: b }
    | { [] }
;

instr:
    | Ldecl; x = Lvar; Lassign; e = expr; Lsc 
        { Decl { name = x; init = e; pos = $startpos } }
    | Lreturn; e = expr; Lsc 
        { Return { e; pos = $startpos($1) } }
    | Lvar; Lassign ; e = expr; Lsc 
        { Assign { name = $1; rhs = e; pos = $startpos } }
    | Lvar; x = Lvar; Lassign; e = expr; Lsc 
        { Decl { name = x; init = e; pos = $startpos } }
    | Lif; e = expr; Loacc; a = block; Lcacc; Lelse; Loacc; b = block; Lcacc 
        { Cond { cond = e; thn = a; els = b; pos = $startpos } }
    | Lloop; e = expr; Loacc; a = block; Lcacc 
        { While { cond = e; body = a; pos = $startpos } }
    | e = expr; Lsc 
        { Expr { e; pos = $startpos } }
;

expr:

| a = expr; Ladd; b = expr  { Call { func = "_add"; args = [ a ; b ];  pos = $startpos } }
| a = expr; Lmul; b = expr  { Call { func = "_mul"; args = [ a ; b ];  pos = $startpos } }
| a = expr; Ldiv; b = expr  { Call { func = "_div"; args = [ a ; b ];  pos = $startpos } }
| a = expr; Lsub; b = expr  { Call { func = "_sub"; args = [ a ; b ];  pos = $startpos } }
| a = expr; Lmod; b = expr  { Call { func = "_mod"; args = [ a ; b ];  pos = $startpos } }
| f = Lvar; Lopar; a = expr; Lcpar 
    { Call { func = f; args = [ a ]; pos = $startpos } }
| a = expr; Land; b = expr  { Call { func = "_and"; args = [ a ; b ];  pos = $startpos } }
| a = expr; Lor;  b = expr  { Call { func = "_or";  args = [ a ; b ];  pos = $startpos } }
| a = expr; Lxor; b = expr  { Call { func = "_xor"; args = [ a ; b ];  pos = $startpos } }
| Lnot;           a = expr  { Call { func = "_not"; args = [ a ];     pos = $startpos } }
| a = expr; Leq;  b = expr  { Call { func = "_eq"; args = [ a ; b ]; pos = $startpos } }
| n = Lint { Int { value = n ; pos = $startpos(n) }}
| b = Lbool { Bool { value = b ; pos = $startpos(b) }}
/* comparaisons */
| a = expr; Linf;  b = expr { Call { func = "_lt"; args = [ a ; b ]; pos = $startpos } }
| a = expr; Linfe; b = expr { Call { func = "_le"; args = [ a ; b ]; pos = $startpos } }
| a = expr; Lsup;  b = expr { Call { func = "_gt"; args = [ a ; b ]; pos = $startpos } }
/* I/O */
| Lprinti; a = expr { Call { func = "_puti"; args = [ a ];  pos = $startpos } }
| Lprintb; a = expr { Call { func = "_putb"; args = [ a ];  pos = $startpos } }
| Lgeti             { Call { func = "_geti"; args = [  ];   pos = $startpos } }
| Lgets             { Call { func = "_gets"; args = []; pos = $startpos } }
| Lgetb             { Call { func = "_getb"; args = []; pos = $startpos } }

/* variables */
| v = Lvar { Var { name = v; pos = $startpos } }
| s = Lstring { String { value = s; pos = $startpos } }
| Lopar; e = expr; Lcpar { e }
;