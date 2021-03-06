%{
  open Ast

  let maxint = Int32.max_int
  let minint = min_int

%}

%token <Ast.constant> CONST
%token <Ast.binop> CMP
%token <string> IDENT

/* TODO tokens por implementar: 
%token DEF ARRAY FILLED BY COM TYPE SIZE OF
%token SLB SRB
*/

%token IF THEN ELSE PRINTINT PRINTBOOL LET IN VAR DO RANGE FOR MAXINT MININT
%token SET EQ SCOL COL NOT AND OR 
%token PLUS MINUS DIV MUL MOD
%token INT BOOL
%token EOF
%token LP RP LB RB

/* definição de prioridades */ 

%left AND 
%left OR
%nonassoc IN
%nonassoc NOT
%nonassoc CMP
%left MOD
%left PLUS 
%left MINUS
%left DIV 
%left MUL
%nonassoc uminus

/* ponto de entrada da gramática */
%start prog

/* tipo dos valores devolvidos pelo analizador */
%type <Ast.program> prog
%% 

prog:
| p = stmts EOF { p }
;

stmts:
| x = stmt             { [x] }
| x = stmt xs = stmts  { x :: xs } 
;

stmt:
| VAR id = IDENT COL t = types EQ e = expr SCOL { Svar (id, t, e) }
| id = IDENT SET e = expr SCOL                  { Sset (id, e) }
| PRINTINT LP e = expr RP SCOL                  { Sprint_int e }
| PRINTBOOL LP e = expr RP SCOL                 { Sprint_bool e }
| IF e = expr THEN LB s1 = stmts RB 
  ELSE LB s2 = stmts RB                         { Sif (e, s1, s2) }
| FOR id = IDENT IN e1 = expr RANGE e2 = expr DO LB
  s = stmts RB                                  { Sforeach (id, e1, e2, s) }
  
;


types:
| INT  {Tint}
| BOOL {Tbool}
;

expr:
| c = CONST                    { Econst c }
| id = IDENT                   { Eident id }
| e1 = expr o = op e2 = expr   { Ebinop (o, e1, e2) }
| NOT e = expr                 { Eunop (Unot, e)} 
| MINUS e = expr %prec uminus  { Eunop (Uneg, e) }
| LET id = IDENT COL t = types EQ e1 = expr 
  IN e2 = expr                 {Elet (id, t, e1, e2)}
| LP e = expr RP               {e}
;

%inline op:
| PLUS  { Badd }
| MINUS { Bsub }
| DIV   { Bdiv }
| MUL   { Bmul }
| MOD   { Bmod}
| c=CMP {c}
| AND   {Band}
| OR    {Bor}
;


