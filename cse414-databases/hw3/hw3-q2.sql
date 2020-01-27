/*
Q2: 109 rows, 8 seconds

Aberdeen SD
Abilene TX
Alpena MI
Ashland WV
Augusta GA
Barrow AK
Beaumont/Port Arthur TX
Bemidji MN
Bethel AK
Binghamton NY
Brainerd MN
Bristol/Johnson City/Kingsport TN
Butte MT
Carlsbad CA
Casper WY
Cedar City UT
Chico CA
College Station/Bryan TX
Columbia MO
Columbus GA
 */

SELECT DISTINCT g.origin_city AS city
FROM (SELECT f.origin_city, MAX(f.actual_time) AS max_time
FROM Flights AS f
GROUP BY f.origin_city) AS g
WHERE g.max_time < 180
ORDER BY city