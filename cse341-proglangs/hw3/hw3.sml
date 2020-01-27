(* Dan Grossman, CSE341, HW3 Provided Code *)

exception NoAnswer

datatype pattern = WildcardP
                 | VariableP of string
                 | UnitP
                 | ConstantP of int
                 | ConstructorP of string * pattern
                 | TupleP of pattern list

datatype valu = Constant of int
              | Unit
              | Constructor of string * valu
              | Tuple of valu list

fun g f1 f2 p =
    let 
        val r = g f1 f2 
    in
        case p of
            WildcardP         => f1 ()
          | VariableP x       => f2 x
          | ConstructorP(_,p) => r p
          | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
          | _                 => 0
    end

(**** for the challenge problem only ****)

datatype typ = AnythingT
             | UnitT
             | IntT
             | TupleT of typ list
             | DatatypeT of string

(**** you can put all your code here ****)

(* #1 *)
fun only_lowercase xs =
    List.filter (fn x => Char.isLower(String.sub(x, 0))) xs

(* #2 *)
fun longest_string1 xs =
    List.foldl (fn (x, y) => if String.size x > String.size y then x else y) ""  xs

(* #3 *)
fun longest_string2 xs =
    List.foldl (fn (x, y) => if String.size y > String.size x then y else x) ""  xs

(* #4 *)
fun longest_string_helper f =
    List.foldl (fn (x, y) => if f(String.size x,  String.size y) then x else y) ""

val longest_string3 =
    longest_string_helper (fn (x, y) => x > y)

val longest_string4 =
    longest_string_helper (fn (x, y) => x >= y)

(* #5 *)
val longest_lowercase =
    longest_string3 o only_lowercase 
	       
(* #6 *)			  
val caps_no_X_string =
   String.implode o List.filter (fn s => s <> #"X") o String.explode o String.map (Char.toUpper)

(* #7 *)
fun first_answer f xs =
    case xs
     of [] => raise NoAnswer
      | x::xs' => case f x
		   of NONE => first_answer f xs'
		    | SOME v => v

(* #8 *)
fun all_answers f xs =
    let
	fun helper ([], acc) = SOME acc
	  | helper (x::xs, acc) = case f x of
				      NONE => NONE
				    | SOME v => helper(xs, v @ acc)
    in
	case xs
	 of [] => SOME []
	  | _ => helper (xs, [])
    end
    
(* #9 *)
(* a *)
(* Function g takes in a unit -> int function, a string -> int function, and a pattern.  It then computes some sort of a count, whose behavior is
   defined by the two given functions and applies f2 and f1 on Variables and Wildcards and returns that count *)

(* b *)
val count_wildcards = g (fn x => 1) (fn x => 0)

(* c *)
val count_wild_and_variable_lengths = g (fn x => 1) (fn str => String.size str)

(* d *)
fun count_a_var (str, p) =
    g (fn x => 0) (fn x => if str = x then 1 else 0) p
	     
(* #10 *)
fun check_pat p =
    let
	fun get_varnames p =
	    case p
	     of VariableP v => [v]
	      | ConstructorP (n, pat) => get_varnames pat
	      | TupleP ps => List.foldl (fn (p, acc) => get_varnames p @ acc) [] ps
	      | _ => [] 
	fun all_unique xs =
	    case xs
	     of [] => true
	      | x::xs' => not (List.exists (fn y => x = y) xs') andalso all_unique xs'
    in
	(all_unique o get_varnames) p
    end

(* #11 *)
fun matches (v, p) =
    case (v, p)
     of (_, WildcardP) => SOME []
      | (_, VariableP var) => SOME [(var, v)]
      | (Unit, UnitP) => SOME []
      | (Constant n1, ConstantP n2) => if n1 = n2 then SOME [] else NONE
      | (Constructor(s1, v'), ConstructorP(s2, p')) => if s1 = s2 then matches(v', p') else NONE
      (* (valu * pattern -> (string * valu) list option) -> (valu * pattern) list -> (string * valu) list option *)
      | (Tuple vs, TupleP ps) => if List.length vs = List.length ps then all_answers matches (ListPair.zip (vs, ps)) else NONE
      | (_, _) => NONE

(* #12 *)
fun first_match v ps =
    SOME (first_answer (fn p => matches (v, p)) ps) handle NoAnswer => NONE
    

fun test v ps =
    fn p => matches (v, p)
