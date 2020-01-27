(* #1: Returns whether the first given date is greater than the second *)
fun is_older (x: int * int * int, y: int * int * int) =
    if #3 x <> #3 y
    then #3 x < #3 y
    else
	if #2 x <> #2 y
	then #2 x < #2 y
	else #1 x < #1 y
			

(* #2: Returns number of dates in list that are in given month *)
fun number_in_month (lst: (int * int * int) list, month: int) =
    if null lst
    then 0
    else
	if #2 (hd(lst)) = month
	then 1 + number_in_month(tl lst, month)
	else number_in_month(tl lst, month)

(* #3: Returns number of dates in list that are in given month *)
fun number_in_months (dates: (int * int * int) list, months: int list) =
    if null months
    then 0
    else number_in_month(dates, hd months) + number_in_months(dates, tl months)
							     
(* #4: Returns dates in list that are in given month *)
fun dates_in_month (dates: (int * int * int) list, month: int) =
    if null dates
    then []
    else if #2(hd dates) = month
    then hd dates :: dates_in_month(tl dates, month)
    else dates_in_month(tl dates, month)
							   
(* #5: Returns dates in list that are in given list of months *)
fun dates_in_months(dates: (int * int * int) list, months: int list) =
    if null months
    then []
    else dates_in_month(dates, hd months) @ dates_in_months(dates, tl months)

(* #6: Returns nth string in list where n of hd list = 1 *)
fun get_nth(list: string list, n: int) =
    if n = 1
    then hd(list)
    else get_nth(tl list, n - 1)

(* #7 Date to String *)
val month_list = ["January", "February", "March", "April", "May", "June", "July",
		 "August", "September", "October", "November", "December"]
		    
fun date_to_string(date: int * int * int) =
    get_nth(month_list, #2 date) ^ "-" ^ Int.toString(#1 date) ^ "-" ^ Int.toString(#3 date)
    
(* #8: Returns index of cumulative summation before reaching given int *)
fun number_before_reaching_sum(sum: int, list: int list) =
    if sum - hd list <= 0
    then 0
    else 1 + number_before_reaching_sum(sum - hd list, tl list)

(* #9 Returns what month a day is in given day of year *)
val days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
				       
fun what_month(day: int) =
    1 + number_before_reaching_sum(day, days_in_month)
    
(* #10 Returns the months of all days between day1 and day2 inclusive *)
fun month_range(day1: int, day2: int) =
    if day1 > day2
    then []
    else what_month(day1) :: month_range(day1 + 1, day2)

(* #11 Finds oldest (min) date in list of dates *)
fun oldest(list: (int * int * int) list) =
    if null list
    then NONE
    else
	let fun oldest_nonempty(list2: (int * int * int) list) =
		if null (tl list2)
		then hd list2
		else
		    let val tl_oldest = oldest_nonempty(tl list2)
		    in
			if is_older(hd list2, tl_oldest)
			then hd list2
			else tl_oldest
		    end
	in
	    SOME (oldest_nonempty list)
	end

(* #12: Returns partial cumulative sum of an int list *)
fun cumulative_sum(list: int list) =
    let fun sum_so_far(sum: int, list2: int list) =
	    if null (tl list2)
	    then sum :: []
	    else sum :: sum_so_far(sum + hd(tl list2), tl list2)
    in
	sum_so_far(hd list, list)
    end

(* Challenge #1 Same as #3 and #5 but removes duplicates from list of months *)			   
	
(*
fun remove(n: int, lst: int list) =
    if null lst
    then []
    else if n = hd lst
    then remove(n, tl lst)
    else hd lst :: remove(n, tl lst)
*)

fun remove_duplicates(xs: int list) =
    if null xs
    then []
    else
	let fun remove(n: int, xs: int list) =
	    if null xs
	    then []
	    else
		if n = hd xs
		then remove(n, tl xs)
		else hd xs :: remove(n, tl xs)
	in
	    hd xs :: remove_duplicates(remove(hd xs, xs))
	end
    
fun number_in_months_challenge(dates: (int * int * int) list, months: int list) =
    number_in_months(dates, remove_duplicates(months))

fun dates_in_months_challenge(dates: (int * int * int) list, months: int list) =
    dates_in_months(dates, remove_duplicates(months))
		   
(* Challenge #2 Checks if a date is a valid date*)
val days_in_month_leap = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

fun get_nth_int(xs: int list, n: int) =
    if n = 1
    then hd(xs)
    else get_nth_int(tl xs, n - 1)
			     
fun reasonable_date(date: int * int * int) =
    if #3 date < 1 orelse #2 date > 12 orelse #2 date < 1 orelse #1 date < 1
    then false
    else
	if (#3 date) mod 400 = 0 orelse (#3 date mod 100 <> 0 andalso #3 date mod 4 = 0)
	then if #1 date > get_nth_int(days_in_month_leap, #2 date)
	     then false
	     else true
	else
	    if #1 date > get_nth_int(days_in_month, #2 date)
	    then false
	    else true
	     
	     
