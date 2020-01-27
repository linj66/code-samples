/*
Q5: 3 rows, like 12 minutes
cities
Hattiesburg/Laurel MS
Devils Lake ND
St. Augustine FL
 */

SELECT h.dest_city AS city
FROM (SELECT DISTINCT h.dest_city
FROM Flights AS h) AS h
WHERE h.dest_city NOT IN
      (SELECT DISTINCT g.dest_city
      FROM Flights AS g
      WHERE g.origin_city = 'Seattle WA'
      UNION
      SELECT DISTINCT g.dest_city
      FROM Flights AS f, Flights AS g
      WHERE f.origin_city = 'Seattle WA'
        AND f.dest_city = g.origin_city)
ORDER BY city