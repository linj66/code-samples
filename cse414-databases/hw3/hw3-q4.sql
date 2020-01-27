/*
Q4: 24 seconds, 256 rows
Aberdeen SD
Abilene TX
Adak Island AK
Aguadilla PR
Akron OH
Albany GA
Albany NY
Alexandria LA
Allentown/Bethlehem/Easton PA
Alpena MI
Amarillo TX
Appleton WI
Arcata/Eureka CA
Asheville NC
Ashland WV
Aspen CO
Atlantic City NJ
Augusta GA
Bakersfield CA
Bangor ME
 */

SELECT DISTINCT g.dest_city AS city
FROM Flights AS f, Flights AS g
WHERE f.origin_city = 'Seattle WA'
  AND f.dest_city = g.origin_city
  AND g.dest_city NOT IN (SELECT DISTINCT f.dest_city
  FROM Flights AS f
  WHERE f.origin_city = 'Seattle WA')
  AND g.dest_city != 'Seattle WA'
ORDER BY city