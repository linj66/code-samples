(* CSE 341, HW2 Provided Code *)

(* main datatype definition we will use throughout the assignment *)
datatype json =
         Num of real (* real is what SML calls floating point numbers *)
       | String of string
       | False
       | True
       | Null
       | Array of json list
       | Object of (string * json) list

(* some examples of values of type json *)
val json_pi    = Num 3.14159
val json_hello = String "hello"
val json_false = False
val json_array = Array [Num 1.0, String "world", Null]
val json_obj   = Object [("foo", json_pi), ("bar", json_array), ("ok", True)]

(* some provided one-liners that use the standard library and/or some features
   we have not learned yet. (Only) the challenge problem will need more
   standard-library functions. *)

(* dedup : string list -> string list -- it removes duplicates *)
fun dedup xs = ListMergeSort.uniqueSort String.compare xs

(* strcmp : string * string -> order compares strings alphabetically
   where datatype order = LESS | EQUAL | GREATER *)
val strcmp = String.compare

(* convert an int to a real *)
val int_to_real = Real.fromInt

(* absolute value of a real *)
val real_abs = Real.abs

(* convert a real to a string *)
val real_to_string = Real.toString

(* return true if a real is negative : real -> bool *)
val real_is_negative = Real.signBit

(* We now load 3 files with police data represented as values of type json.
   Each file binds one variable: small_incident_reports (10 reports),
   medium_incident_reports (100 reports), and large_incident_reports
   (1000 reports) respectively.

   However, the large file is commented out for now because it will take
   about 15 seconds to load, which is too long while you are debugging
   earlier problems.  In string format, we have ~10000 records -- if you
   do the challenge problem, you will be able to read in all 10000 quickly --
   it's the "trick" of giving you large SML values that is slow.
*)

(* Make SML print a little less while we load a bunch of data. *)
       ; (* this semicolon is important -- it ends the previous binding *)
Control.Print.printDepth := 3;
Control.Print.printLength := 3;

use "parsed_small_police.sml";
use "parsed_medium_police.sml";

(* uncomment when you are ready to do the problems needing the large report*)
use "parsed_large_police.sml";

val large_incident_reports_list =
    case large_incident_reports of
        Array js => js
      | _ => raise (Fail "expected large_incident_reports to be an array")

(* Now make SML print more again so that we can see what we're working with. *)
; Control.Print.printDepth := 20;
Control.Print.printLength := 20;

(**** PUT PROBLEMS 1-8 HERE ****)

(* #1 *)
fun make_silly_json i =
    let
	fun make 0 = []
	  | make x = Object [("n", Num (int_to_real x)), ("b", True)] :: make (x - 1)
    in
	Array (make i)
    end
	

(* #2 *)
fun assoc (k, xs) =
	     case xs of
		 [] => NONE
	       | (k', v)::tail =>
		 case k' = k of
		     true => SOME v
		   | false => assoc(k, tail)

(* #3 *)
fun dot (j, f) =
    case j of
	Object obj => assoc (f, obj)
      | _ => NONE
	
(* #4 *)
fun one_fields j =
    case j of
	Object obj =>
	let
	    fun get_names (j', acc) =
		case j' of
		    [] => acc
		  | (k, _) :: tail => get_names(tail, k :: acc)
	in
	    get_names(obj, [])
	end
      | _  => [] 
	
(* #5 *)
fun no_repeats xs =
    length xs = length (dedup xs)

(* #6 *)	       
fun recursive_no_field_repeats j =
    let
	fun process (Array (x::xs)) = recursive_no_field_repeats x andalso process (Array xs)
	  | process (Object ob) =
	    let
		fun get_values ([], acc) = acc
		  | get_values ((_, v) :: tail, acc) = get_values(tail, v :: acc)
	    in
		no_repeats(one_fields j) andalso process (Array(get_values (ob, [])))
	    end
	  | process _ = true
    in
	process j
    end

(* #7 *)
fun count_occurrences (xs, ex) =
    let
	fun help_count (xs', str, count, acc) =
	    case xs' of
		[] => (str, count) :: acc
	      | x::tail =>
		case strcmp (str, x) of
		     LESS => help_count(tail, x, 1, (str, count) :: acc)
		   | EQUAL => help_count(tail, x, count + 1, acc)
		   | GREATER => raise ex
    in
	case xs of
	    [] => []
	  | x::tail => help_count(tail, x, 1, [])
    end
    
(* #8 *)
fun string_values_for_field (str, xs) =
    case xs of
	[] => []
      | head::tail =>
	case dot(head, str) of
	    SOME (String v) => v::string_values_for_field(str, tail)
	  | _ => string_values_for_field(str, tail)					   
    
(* histogram and historgram_for_field are provided, but they use your
   count_occurrences and string_values_for_field, so uncomment them
   after doing earlier problems *)

(* histogram_for_field takes a field name f and a list of objects js and
   returns counts for how often a string is the contents of f in js. *)

exception SortIsBroken

fun histogram (xs : string list) : (string * int) list =
  let
    fun compare_strings (s1 : string, s2 : string) : bool = s1 > s2

    val sorted_xs = ListMergeSort.sort compare_strings xs
    val counts = count_occurrences (sorted_xs,SortIsBroken)

    fun compare_counts ((s1 : string, n1 : int), (s2 : string, n2 : int)) : bool =
      n1 < n2 orelse (n1 = n2 andalso s1 < s2)
  in
    ListMergeSort.sort compare_counts counts
  end

fun histogram_for_field (f,js) =
  histogram (string_values_for_field (f, js))


(**** PUT PROBLEMS 9-11 HERE ****)

;Control.Print.printDepth := 3;
Control.Print.printLength := 3;

(* #9 *)
fun filter_field_value (a, b, xs) =
    case xs of
	[] => []
      | head::tail =>
	case dot(head, a) of
	    SOME (String v) =>
	    (case b = v of
		 true => head::filter_field_value(a, b, tail)
	       | false => filter_field_value(a, b, tail))
	  | _ => filter_field_value(a, b, tail)

(* #10 *)
val large_event_clearance_description_histogram =
    histogram_for_field("event_clearance_description", large_incident_reports_list)

(* #11 *)
val large_hundred_block_location_histogram =
    histogram_for_field("hundred_block_location", large_incident_reports_list)

(**** PUT PROBLEMS 12-15 HERE ****)

;Control.Print.printDepth := 20;
Control.Print.printLength := 20;

(* #12 *)
val forty_third_and_the_ave_reports =
    filter_field_value("hundred_block_location", "43XX BLOCK OF UNIVERSITY WAY NE", large_incident_reports_list)

(* #13 *)
val forty_third_and_the_ave_event_clearance_description_histogram =
    histogram_for_field("event_clearance_description", forty_third_and_the_ave_reports)

(* #14 *)
val nineteenth_and_forty_fifth_reports =
    filter_field_value("hundred_block_location", "45XX BLOCK OF 19TH AVE NE", large_incident_reports_list)

(* #15 *)
val nineteenth_and_forty_fifth_event_clearance_description_histogram =
    histogram_for_field("event_clearance_description", nineteenth_and_forty_fifth_reports)

(**** PUT PROBLEMS 16-19 HERE ****)

(* #16 *)
fun concat_with (x, xs) =
    case xs of
	[] => ""
      | x'::[] => x'
      | x'::xs' => x' ^ x ^ concat_with(x, xs')

(* #17 *)
fun quote_string x = "\"" ^ x ^ "\""

(* #18 *)
fun real_to_string_for_json r =
    if real_is_negative r
    then "-" ^ real_to_string(real_abs r)
    else real_to_string r

(* #19 *)
fun json_to_string j =
    let
	fun process (Array arr) =
	    (case arr of
		[] => []
	      | x::xs => (json_to_string x)::(process (Array xs)))
	  | process (Object obj) =
	    (case obj of
		[] => []
	      | (x, y)::xs => (quote_string x ^ " : " ^ json_to_string y)::(process (Object xs)))
	  | process _ = ["bogus"] (* should never reach here--getting rid of warning: match non-exhaustive *) 
    in
	case j of
	    Num n => real_to_string_for_json n
	  | String s => quote_string s
	  | False => "false"
	  | True => "true"
	  | Null => "null"
	  | Array ar => "[" ^ concat_with(", ", process j) ^ "]"
	  | Object ob => "{" ^ concat_with(", ", process j) ^ "}"
    end
(* For CHALLENGE PROBLEMS, see hw2challenge.sml *)
