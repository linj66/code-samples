/*
Q3: 327 rows, 15 seconds

Guam TT
Pago Pago TT
Aguadilla PR	29
Anchorage AK	32
San Juan PR	33
Charlotte Amalie VI	40
Ponce PR	41
Fairbanks AK	50
Kahului HI	53
Honolulu HI	54
Los Angeles CA	56
San Francisco CA	56
Seattle WA	57
Long Beach CA	62
Kona HI	63
New York NY	63
Las Vegas NV	65
Christiansted VI	65
Worcester MA	67
Newark NJ	67
 */

SELECT g.origin_city, f.num_less * 100 / g.num_less AS percentage
FROM (SELECT f.origin_city, COUNT(f.origin_city) AS num_less
FROM Flights AS f
GROUP BY f.origin_city) AS g
  LEFT JOIN (SELECT f.origin_city, COUNT(f.origin_city) AS num_less
FROM Flights AS f
WHERE f.actual_time < 180
GROUP BY f.origin_city) AS f ON f.origin_city = g.origin_city
ORDER BY percentage

