open Ast
open Lexing

exception Error of string

let localisation pos inFile =
  let l = pos.pos_lnum in
  let c = pos.pos_cnum - pos.pos_bol + 1 in
  Printf.printf "File \"%s\", line %d, characters %d-%d:\n" !inFile l (c-1) c

let unboundVarError x = raise (Error ("Unbound value " ^ x))

let typeError t1 t2 =
  let string_of_type = function 
    | Tint -> "int"
    | Tbool -> "bool"
  in let s = "Type error: This expression has type " ^ (string_of_type t2) ^ 
             " but an expression was expected of type " ^ (string_of_type t1)
  in raise (Error s)

let invalidOperand () = raise (Error "Invalid operand")

let divisionBy0 () = raise (Error "Division by zero")