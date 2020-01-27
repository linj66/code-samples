use "hw2.sml";

val obj_unique = Object [("foo", Num 1.0), ("bar", True), ("baz", String "boo"), ("dab", False)]

val obj_unique2 = Object[("aa", Num 1.0), ("bb", Num 2.0), ("cc", Num 3.0)]

val obj_dupl = Object [("foo", Num 1.0), ("bar", True), ("baz", String "boo"), ("bar", False)]

val obj_nested = Object [("foo", Num 1.0), ("bar", True), ("baz", String "boo"), ("dab", False), ("obj", obj_unique2)]

val obj_nested2 = Object [("foo", Num 1.0), ("bar", True), ("baz", String "boo"), ("dab", False), ("obj", obj_dupl)]

val arr_reg = Array [String "string", Num 1.0, False, True]

val arr_obj_unique = Array [String "string", Num 1.0, False, True, obj_unique]

val arr_obj_dupl = Array [String "string", Num 1.0, False, True, obj_dupl]

val arr_obj_nested = Array [String "string", Num 1.0, False, True, arr_obj_unique]

val arr_obj_nested2 = Array [String "string", Num 1.0, False, True, arr_obj_dupl]

val arr_obj_hella_nested = Array [String "string", Num 1.0, False, True, arr_obj_nested2]

				 val obj_string = Object([("foo", String "oof"), ("bar", String "rab"), ("baz", String "zab"), ("dab", String "bad"), ("ree", String "eer")])

val obj_string2 = Object([("tom", String "mot"), ("foo", String "oof"), ("tom", String "mot2")])

val obj_string3 = Object([("honda", String "civic"), ("toyota", String "corolla"), ("mazda", String "rx7"), ("lancia", String "delta")])

val obj_many_civic = Object([("honda", String "civic"),
			     ("honda", String "civic"),
			     ("honda", String "civic"),
			     ("honda", String "civic"),
			     ("honda", String "civic"),
			     ("honda", String "civic"),
			     ("honda", String "civic"),
			     ("honda", String "civic"),
			     ("honda", String "civic"),
			     ("honda", String "civic")])

val three_obj_list = [obj_string, obj_string2, obj_string3]
val three_obj_list_and = [String "bar", False, obj_string, obj_string2, obj_string3]

val three_obj_list_civic = [obj_string, obj_string2, obj_string3, obj_many_civic]

				 (* #19 *)
val test19_arr = json_to_string arr_reg
val test19_arr_nest = json_to_string arr_obj_dupl
val test19_obj_nest = json_to_string obj_nested2
val test19_omg = json_to_string arr_obj_hella_nested

(* #1 *)
val test1_1 = make_silly_json 2
val test1_2 = make_silly_json 10

(* #2 *)
val test2 = assoc("foo", [("bar", "rab"), ("foo", "oof"), ("doofus", "lmao")])
val test2_1 = assoc("bogus", [("bar", "rab"), ("foo", "oof"), ("doofus", "lmao")])

(* #3 *)
val test3_not_obj = dot(False, "foo")
val test3_not_present = dot(Object [("bogus", String "bogus"), ("reallybogus", String "reallybogus")], "foo")
val test3_legit = dot(Object [("lol", String "rip"), ("sah", String "dab"), ("foo", String "oof"), ("ree", String "ez")], "foo")

(* #4 *)
val test4_1 = one_fields obj_unique
val test4_2 = one_fields obj_dupl
val test4_bogus = one_fields (Array [String "lol", String "ree", String "sah", String ":D", Null])
val test4_empty = one_fields (Object [])

(* #5 *)
val test5_legit = no_repeats ["bar", "foo", "baz"]
val test5_bogus = no_repeats ["honda", "honda", "honda"]
val test5_empty = no_repeats []			      

(* #6 *)
val test6_reg1 = recursive_no_field_repeats (Num 1.0)
val test6_reg2 = recursive_no_field_repeats (False)
val test6_obj_u = recursive_no_field_repeats obj_unique
val test6_obj_u2 = recursive_no_field_repeats obj_unique2
val test6_arr = recursive_no_field_repeats arr_reg
val test6_obj_dupl = recursive_no_field_repeats obj_dupl
val test6_obj_nu = recursive_no_field_repeats obj_nested
val test6_obj_nd = recursive_no_field_repeats obj_nested2
val test6_arr_obju = recursive_no_field_repeats arr_obj_unique
val test6_arr_objd = recursive_no_field_repeats arr_obj_dupl
val test6_arr_nu = recursive_no_field_repeats arr_obj_nested
val test6_arr_nd = recursive_no_field_repeats arr_obj_nested2

(* #7 *)
val test7_legit = count_occurrences (["foo", "fop", "fox", "foxe", "foz"], SortIsBroken)
val test7_bogus = count_occurrences (["foo", "moo", "loo", "boo"], SortIsBroken)
val test7_empty = count_occurrences ([], SortIsBroken)
					      
(* #8 *)

val test8_obj = string_values_for_field("bar", three_obj_list)
val test8_obj2 = string_values_for_field("mazda", three_obj_list)
val test8_obj3 = string_values_for_field("foo", three_obj_list)
val test8_objn = string_values_for_field("not in", three_obj_list)
val test8_objO = string_values_for_field("foo", three_obj_list_and)
val test8_obje = string_values_for_field("foo", [])
				       
(* #9 *)
val test9_1 = filter_field_value("toyota", "corolla", three_obj_list)
val test9_2 = filter_field_value("toyota", "corolla", three_obj_list_and)
val test9_3 = filter_field_value("foo", "oof", three_obj_list)
val test9_4 = filter_field_value("foo", "oof", three_obj_list_and)
val test9_5 = filter_field_value("toyota", "civic", three_obj_list)
val test9_6 = filter_field_value("honda", "corolla", three_obj_list)
val test9_7 = filter_field_value("honda", "civic", three_obj_list_civic)
val test9_8 = filter_field_value("bogus", "bogus", three_obj_list_and)
val test9_9 = filter_field_value("honda", "civic", [])

(* #16 *)
val test16 = concat_with ("--", ["honda", "civic", "accord", "prelude", "crx", "del sol", "s2000"])

(* #17 *)
val test17 = quote_string "honda"

(* #18 *)
val test18_pos = real_to_string_for_json 5.0
val test18_neg = real_to_string_for_json ~5.0


