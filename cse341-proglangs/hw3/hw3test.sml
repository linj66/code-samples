(* hw3 tests *)
use "hw3.sml";

val str_list = ["BAR", "Bar", "bAR", "bar", "foo", "bZz", "dab"]
val str_list2 = ["", "cc", "ddd", "adafdadsf"]
val wild_pattern = ConstructorP ("wild", TupleP [ConstantP 17, UnitP, VariableP "x", WildcardP, TupleP [VariableP "x", WildcardP]])

val some_pattern = TupleP [VariableP "a", VariableP "b", UnitP, VariableP "c"]

val some_value = Tuple [Constant 1, Constant 2, Unit, Constant 3]
val not_some_value = Tuple [Constant 1, Constant 2, Constant 123, Constant 4]

val wild_value = Constructor ("wild", Tuple [Constant 17, Unit, Constant 1, Constant 2, Tuple [Constant 1, Constant 100]])

val sad_pattern = ConstructorP ("sad", UnitP)

val test1_1 = only_lowercase str_list
val test1_2 = only_lowercase str_list2
val test2_1 = longest_string1 str_list
val test2_2 = longest_string1 str_list2
val test3_1 = longest_string2 str_list
val test3_2 = longest_string2 str_list2
val test4_1 = longest_string3 str_list
val test4_2 = longest_string4 str_list
val test5_1 = longest_lowercase ["DDD", "CCC", "DDDDDD", "c"]
val test5_2 = longest_lowercase ["ddd", "CCC", "DDDDDD", "c"]
val test5_3 = longest_lowercase ["DDD", "CCC", "DDDDDD"]
val test6_1 = caps_no_X_string "Xavier"
val test6_2 = caps_no_X_string "XxXTXoxyxoxtXaxxXXXXXxxxX"
val test9b_1 = count_wildcards some_pattern
val test9b_2 = count_wildcards wild_pattern
val test9c_1 = count_wild_and_variable_lengths some_pattern
val test9c_2 = count_wild_and_variable_lengths wild_pattern
val test9d_1 = count_a_var ("x", wild_pattern)
val test9d_2 = count_a_var ("ccc", wild_pattern)
val test9d_3 = count_a_var ("a", some_pattern)
val test10_true = check_pat some_pattern
val test10_false = check_pat wild_pattern
val test11_some_true = matches (some_value, some_pattern)
val test11_some_false = matches (not_some_value, some_pattern)
val test11_wild_true = matches (wild_value, wild_pattern)
val test12_1 = first_match some_value []
val test12_2 = first_match some_value [sad_pattern, wild_pattern, some_pattern]
			    
